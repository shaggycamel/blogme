library(devtools)

# Package creation
# create_package(here::here())
use_mit_license("Oliver Eaton")

# Dependencies
deps <- c("purrr", "htmltools", "yaml", "leaflet", "fs", "dplyr", "stringr", "here", "glue", "readr")
purrr::walk(deps, ~ use_package(.x, type = "Imports"))

use_dev_package("mapBliss", "Imports", "https://github.com/benyamindsmith/mapBliss.git")

# Other bits and bobs
# use_readme_md()
# use_news_md()
# use_test("my-test")
# use_git()

# Package functions
use_r("carousel")
use_r("plot_route")
use_r("image_processing")

# Load all functions
load_all()

# test
# carousel("city", "/Users/fred/git/travel_blog/posts/albania-tirana/media_data/city/city.yml")
# mogrify("jordan-amman")
# create_image_yaml("jordan-amman")

destinations <- list(
  "ضانا" = list(label="Dana", transport=NA, label_pos="top"),
  "Amman" = list(label="Amman", transport="car", label_pos="top")
)

blogme::plot_route(
  names(destinations),
  how = purrr::map_chr(destinations, "transport"),
  label_text = purrr::map_chr(destinations, "label"),
  label_position = purrr::map_chr(destinations, "label_pos"),
  weight=3,
  colour="blue"
)


##### HOW IS NAMESPACE FILE BUILT??
## Need to include fucntions with @export in namespace file somehow...

setwd("~/git/india_blog_24")
library(dplyr)
library(stringr)

media_dir_path <- paste0(getwd(), "/posts/delhi-entry/media_data/")

get_image_dirs <- fs::dir_info(media_dir_path) |>
    mutate(dir = str_remove(path, media_dir_path), .after = path)

x <- purrr::map(get_image_dirs$path, fs::dir_info) |>
  purrr::list_rbind() |>
  filter(str_detect(path, ".JPG"), size > as_fs_bytes("250Kb")) |>
  mutate(div_factor = size / as_fs_bytes("50Kb"))

purrr::walk2(x$path, x$div_factor, \(x, y){
  print(y)
  print(y * 2)
  cat("\n")
})

