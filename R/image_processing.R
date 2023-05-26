

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
#' @export
mogrify <- function(media_dir_path){

  # Get media directory path
  media_dir_path <- get_media_dir_path(media_dir_path)

  # Get names of all directories in media_data dir
  image_dirs <- get_image_dirs(media_dir_path)

  for(path in image_dirs$path){

    # Replace "jpg" with "JPG"
    rename_jpg(path)

    # Execute mogrify command
    system(glue("(cd /; mogrify -quality 40 -resize 30% {path}/*.JPG)"))

  }
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
rename_jpg <- function(path){
  file_move(dir_ls(path), str_replace(dir_ls(path), ".jpg", ".JPG"))
}

