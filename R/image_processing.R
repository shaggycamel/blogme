

# Create Image YAML -------------------------------------------------------

#' @export
create_image_yaml <- function(media_dir_path){

  # Get media directory path
  media_dir_path <- get_media_dir_path(media_dir_path)

  # Get names of all directories in media_data dir
  image_dirs <- get_image_dirs(media_dir_path)

  # loop through image dirs and create yaml files
  purrr::walk2(image_dirs$dir, image_dirs$path, ~ {
  # for(dir in image_dirs$dir){ ##### -- map2 here instead, to obtain path....

    rename_jpg(.y)

    # Get names of images in image directories
    images <- fs::dir_info(paste0(media_dir_path, .x, "/")) |>
      dplyr::filter(stringr::str_ends(path, ".jpg|.JPG")) |>
      dplyr::mutate(file_name = stringr::str_remove(path, paste0(media_dir_path, .x, "/")), .after = path) |>
      dplyr::arrange(birth_time)

    # Create strings describing images in directories
    img_ls <- purrr::map2(.x, images$file_name, ~ {
      t_dir <- stringr::str_to_title(stringr::str_replace_all(.x, "_", " "))
      stringr::str_glue('
                        - image: "media_data/{.x}/{.y}"
                          caption: "{t_dir}"
                        \n'
      )
    })

    # Write description to yaml files
    readr::write_lines(img_ls, paste0(media_dir_path, .x, "/", .x, ".yml"))

  })
}


# Mogrify -----------------------------------------------------------------

mogrify <- function(media_dir_path){

  # Get media directory path
  media_dir_path <- get_media_dir_path(media_dir_path)

  # Get names of all directories in media_data dir
  image_dirs <- get_image_dirs(media_dir_path)

  for(path in image_dirs$path){

    # Replace "jpg" with "JPG"
    rename_jpg(path)

    # Execute mogrify command
    system(glue::glue("(cd /; mogrify -quality 40 -resize 30% {path}/*.JPG)"))

  }
  cat("Successful mogrification...")
}


# Helpers -----------------------------------------------------------------

# Get media_dir_path: append "media_data" to the end of directory path
get_media_dir_path <- function(media_dir_path) {
  paste0(here::here(), "/", media_dir_path, "/media_data/")
}

# Get names of directories
get_image_dirs <- function(media_dir_path){
  fs::dir_info(media_dir_path) |>
    dplyr::mutate(dir = stringr::str_remove(path, media_dir_path), .after = path)
}

# Rename files function: replace "jpg" with "JPG"
rename_jpg <- function(path){
  fs::file_move(fs::dir_ls(path), stringr::str_replace(fs::dir_ls(path), ".jpg", ".JPG"))
}

