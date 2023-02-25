library(usethis)
library(here)

create_package(here())

use_mit_license("Oliver Eaton")
use_package("mapBliss", "purrr")
use_readme_md()
use_news_md()
use_test("my-test")
use_git()
