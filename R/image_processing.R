

# Create Image YAML -------------------------------------------------------
#' @importFrom readr write_lines
#' @importFrom fs dir_info
#' @importFrom purrr map2
#' @importFrom purrr walk2
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr arrange
#' @importFrom stringr str_ends
#' @importFrom stringr str_remove
#' @importFrom stringr str_to_title
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_glue
#' @export
create_image_yaml <- function(media_dir_path){

  # Get media directory path
  media_dir_path <- get_media_dir_path(media_dir_path)

  # Get names of all directories in media_data dir
  image_dirs <- get_image_dirs(media_dir_path)

  # loop through image dirs and create yaml files
  walk2(image_dirs$dir, image_dirs$path, ~ {

    rename_jpg(.y)

    # Get names of images in image directories
    images <- dir_info(paste0(media_dir_path, .x, "/")) |>
      filter(str_ends(path, ".jpg|.JPG")) |>
      mutate(file_name = str_remove(path, paste0(media_dir_path, .x, "/")), .after = path) |>
      arrange(birth_time)

    # Create strings describing images in directories
    img_ls <- map2(.x, images$file_name, ~ {
      t_dir <- str_to_title(str_replace_all(.x, "_", " "))
      str_glue('
                        - image: "media_data/{.x}/{.y}"
                          caption: "{t_dir}"
                        \n'
      )
    })

    # Write description to yaml files
    write_lines(img_ls, paste0(media_dir_path, .x, "/", .x, ".yml"))

  })
}


# Mogrify -----------------------------------------------------------------

#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
#' @importFrom purrr walk2
#' @importFrom fs dir_info
#' @importFrom fs as_fs_bytes
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom stringr str_detect
#' @export
mogrify <- function(media_dir_path){

  # Get media directory path
  media_dir_path <- get_media_dir_path(media_dir_path)

  # Get names of all directories in media_data dir
  image_dirs <- get_image_dirs(media_dir_path)

  # Get all images
  images <- map(image_dirs$path, \(x) dir_info(x)) |>
    bind_rows() |>
    filter(str_detect(path, "(?i)\\.jpe?g"), size > as_fs_bytes("250Kb")) |>
    mutate(div_factor = ceiling((as.numeric(as_fs_bytes("500Mb")) / as.numeric(size)))) |>
    mutate(div_factor = if_else(div_factor > 100, 95, div_factor))
    # experiment with div_factor calc

  # Operate on images
  walk2(images$path, images$div_factor, \(x, y){

    # Replace "jpg" with "JPG"
    rename_jpg(x)
    x <- str_remove_all(str_replace(x, regex("\\.jpe?g", ignore_case=TRUE), "\\.JPG"), " ")

    # Execute mogrify command
    system(glue("(cd /; /opt/homebrew/bin/magick mogrify -quality {y} -resize 30% {x})"))

  })

  cat("Successful mogrification...")
}


# Helpers -----------------------------------------------------------------

# Get media_dir_path: append "media_data" to the end of directory path
#' @importFrom here here
get_media_dir_path <- function(media_dir_path) {
  paste0(here(), "/", media_dir_path, "/media_data/")
}

# Get names of directories
#' @importFrom fs dir_info
#' @importFrom dplyr mutate
#' @importFrom stringr str_remove
get_image_dirs <- function(media_dir_path){
  dir_info(media_dir_path) |>
    mutate(dir = str_remove(path, media_dir_path), .after = path)
}

# Rename files function: replace "jpg" with "JPG"
#' @importFrom fs file_move
#' @importFrom fs dir_ls
#' @importFrom stringr str_replace
#' @importFrom stringr str_detect
rename_jpg <- function(path){
  if(str_detect(path, "\\.")){
    file_move(path, str_remove_all(str_replace(path, c(regex("\\.jpe?g", ignore_case=TRUE)), "\\.JPG"), " "))
  } else {
    file_move(dir_ls(path), str_remove_all(str_replace(dir_ls(path), regex("\\.jpe?g", ignore_case=TRUE), "\\.JPG"), " "))
  }
}
