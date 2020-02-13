#' @importFrom tibble tibble
NULL

#' Data describing several hand-picked events that affected
#' traffic flow in the region of Tyne and Wear in the year 2018:
#'
#' @format A tibble containing the following columns:
#' \describe{
#' \item{\code{id}}{event id}
#' \item{\code{date}}{event date}
#' \item{\code{start_datetime}}{event window start time}
#' \item{\code{end_datetime}}{event window end time}
#' \item{\code{event_time}}{when the event was reported on twitter}
#' \item{\code{tweet}}{tweet content}
#' \item{\code{link}}{url link to the original tweet}
#' }
#'
"metadata"
