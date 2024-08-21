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

