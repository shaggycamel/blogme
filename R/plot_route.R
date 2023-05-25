plot_route <- function(names, how, label_text, label_position, weight, colour) {
  m <-
    mapBliss::plot_hybrid_route_flex(
      addresses = names,
      how = na.omit(how),
      label_text = as.vector(label_text),
      label_position = as.vector(label_position),
      weight = weight,
      colour = colour
    ) |>
    leaflet::addScaleBar(position = "bottomleft")

  m$x$options$zoomControl <- TRUE
  m
}
