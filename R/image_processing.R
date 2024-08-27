
# Clean file names --------------------------------------------------------

# Clean file names
#' @importFrom dplyr mutate
#' @importFrom stringr str_remove
#' @importFrom stringr str_replace_all
#' @importFrom purrr walk2
#' @importFrom fs file_move
#' @export
clean_file_names <- function(media_dir_path, image_type=".JPG"){

  images <- get_images(media_dir_path, image_type) |>
    mutate(new_path = str_remove(path, possible_extensions[[image_type]])) |>
    mutate(new_path = str_replace_all(new_path, c("\\."="-", " "=""))) |>
    mutate(new_path = paste0(new_path, image_type))

  walk2(images$path, images$new_path, \(x, y) file_move(x, y))

}


# Create Image YAML -------------------------------------------------------
#' @importFrom dplyr arrange
#' @importFrom dplyr nest_by
#' @importFrom purrr walk
#' @importFrom purrr map
#' @importFrom stringr str_extract
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_to_title
#' @importFrom stringr str_glue
#' @importFrom readr write_lines
#' @export
create_image_yaml <- function(media_dir_path, image_type=".JPG"){

  # Get images
  images <- get_images(media_dir_path, image_type) |>
    arrange(birth_time) |>
    nest_by(dir, .keep = TRUE)

  walk(images$data, \(x){

    # Create strings describing images in directories
    img_ls <- map(x$path, \(x){

        t_img <- str_extract(x, "\\w+\\/[0-9a-zA-Z-_]*\\.JPG")
        t_dir <- str_extract(t_img, "\\w+\\/") |> str_replace_all(c("_"=" ", "\\/"="")) |> str_to_title()
        str_glue('
                          - image: "media_data/{t_img}"
                            caption: "{t_dir}"
                          \n'
        )
      })

      # Write description to yaml files
    write_lines(img_ls, paste0(x$dir[1], "/", str_extract(x$dir[1], "\\w+$"), ".yml"))
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
#' @importFrom rlang set_names
#' @export
mogrify <- function(media_dir_path, image_type=".JPG"){

  # Get images
  images <- get_images(media_dir_path, image_type) |>
    filter(size > as_fs_bytes("300Kb"))

  images_tmp <- map(images$path, \(x){
    t_ls <- system(glue("(cd /; /opt/homebrew/bin/identify -format '%h %w' {x})"), intern = TRUE) |>
      str_split_1(" ") |>
      set_names("height", "width") |>
      as.list()

    t_ls["path"] = x
    as.data.frame(t_ls)
  }) |>
    list_rbind() |>
      mutate(across(c(height, width), as.numeric)) |>
      mutate(area = height * width)

  images <- left_join(images, images_tmp, by = join_by(path))
  images$resize_factor <- predict(resize_factor_model, images, type = "response")
  images <- mutate(images, resize_factor = trunc(resize_factor * 100))

  # Operate on images
  walk2(images$path, images$resize_factor, \(x, y){

    # Execute mogrify command
    system(glue("(cd /; /opt/homebrew/bin/magick {x} -define jpeg:extent=300Kb -resize {y}% {x})"))

  })

  cat("Successful mogrification...")
}


# Helpers -----------------------------------------------------------------

# Get names of images
#' @importFrom here here
#' @importFrom fs dir_info
#' @importFrom purrr map
#' @importFrom purrr list_rbind
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom stringr str_detect
get_images <- function(media_dir_path, image_type=".JPG"){

  dirs <- paste0(here(), "/", media_dir_path, "/media_data/") |>
    dir_info()

  images <- map(dirs$path, \(x){
    dir_info(x) |>
      mutate(dir = x)
  }) |>
    list_rbind() |>
    filter(str_detect(path, possible_extensions[[image_type]]))

  images
}


