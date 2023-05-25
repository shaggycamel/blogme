
# carousel displays a list of items w/ nav buttons
#' @export
carousel <- function(id, items) {
  index <- -1
  items <- yaml::yaml.load_file(items)
  items <- lapply(items, function(item) {
    index <<- index + 1
    carouselItem(item$caption, item$image, index)
  })

  indicators <- htmltools::div(class = "carousel-indicators", htmltools::tagList(lapply(items, function(item) item$button)))
  items <- htmltools::div(class = "carousel-inner", htmltools::tagList(lapply(items, function(item) item$item)))

  htmltools::div(
    id = id,
    class = "carousel carousel-dark slide",
    `data-bs-interval` = "false",
    indicators,
    items,
    navButton(id, "prev", "Prevoius"),
    navButton(id, "next", "Next")
  )
}

# carousel item
carouselItem <- function(caption, image, index) {
  id <- paste0("gallery-carousel-item-", index)
  button <- htmltools::tags$button(
    type = "button",
    `data-bs-target` = "#gallery-carousel",
    `data-bs-slide-to` = index,
    `aria-label` = paste("Slide", index + 1)
  )

  if (index == 0) button <- htmltools::tagAppendAttributes(button, class = "active", `aria-current` = "true")

  item <- htmltools::div(
    class = paste0("carousel-item", ifelse(index == 0, " active", "")),
    htmltools::img(src = image, class = "d-block mx-auto border", style = "max-width:600px; max-height:600px; height:auto; width:auto;"),
    htmltools::br(),
    htmltools::br(),
    htmltools::br(),
    htmltools::br(),
    htmltools::div(class = "carousel-caption d-none d-md-block", htmltools::p(class = "fw-light", caption))
  )

  list(button = button, item = item)
}

# nav button
navButton <- function(targetId, type, text) {
  htmltools::tags$button(
    class = paste0("carousel-control-", type),
    type = "button",
    `data-bs-target` = paste0("#", targetId),
    `data-bs-slide` = type,
    htmltools::span(class = paste0("carousel-control-", type, "-icon"), `aria-hidden` = "true"),
    htmltools::span(class = "visually-hidden", text)
  )
}
