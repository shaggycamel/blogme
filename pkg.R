library(usethis)
library(here)

# create_package(here())

use_mit_license("Oliver Eaton")
use_package("purrr", "Imports")
use_dev_package("mapBliss", "Imports", "https://github.com/benyamindsmith/mapBliss.git")
use_readme_md()
use_news_md()
use_test("my-test")
use_git()
