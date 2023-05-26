
# carousel displays a list of items w/ nav buttons
#' @importFrom yaml yaml.load_file
#' @import htmltools
#' @export
carousel <- function(id, items) {
  index <- -1
  items <- yaml.load_file(items)
  items <- lapply(items, function(item) {
    index <<- index + 1
    carouselItem(item$caption, item$image, index)
  })

  indicators <- div(class = "carousel-indicators", tagList(lapply(items, function(item) item$button)))
  items <- div(class = "carousel-inner", tagList(lapply(items, function(item) item$item)))

  div(
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
  button <- tags$button(
    type = "button",
    `data-bs-target` = "#gallery-carousel",
    `data-bs-slide-to` = index,
    `aria-label` = paste("Slide", index + 1)
  )

  if (index == 0) button <- tagAppendAttributes(button, class = "active", `aria-current` = "true")

  item <- div(
    class = paste0("carousel-item", ifelse(index == 0, " active", "")),
    img(src = image, class = "d-block mx-auto border", style = "max-width:600px; max-height:600px; height:auto; width:auto;"),
    br(),
    br(),
    br(),
    br(),
    div(class = "carousel-caption d-none d-md-block", p(class = "fw-light", caption))
  )

  list(button = button, item = item)
}

# nav button
navButton <- function(targetId, type, text) {
  tags$button(
    class = paste0("carousel-control-", type),
    type = "button",
    `data-bs-target` = paste0("#", targetId),
    `data-bs-slide` = type,
    span(class = paste0("carousel-control-", type, "-icon"), `aria-hidden` = "true"),
    span(class = "visually-hidden", text)
  )
}
