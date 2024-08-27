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
# use_r("carousel")
# use_r("plot_route")
# use_r("image_processing")

# Load all functions
load_all()


##### Build NAMESPACE file with:
devtools::document()

