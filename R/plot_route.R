#' @importFrom mapBliss plot_hybrid_route_flex
#' @importFrom leaflet addScaleBar
#' @export
plot_route <- function(names, how, label_text, label_position, weight, colour) {
  m <-
    plot_hybrid_route_flex(
      addresses = names,
      how = na.omit(how),
      label_text = as.vector(label_text),
      label_position = as.vector(label_position),
      weight = weight,
      colour = colour
    ) |>
    addScaleBar(position = "bottomleft")

  m$x$options$zoomControl <- TRUE
  m
}
