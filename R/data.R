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

#' Event data for hand-picked events that affected
#' traffic flow in the region of Tyne and Wear in the year 2018.
#'
#' Includes traffic flow data acquired from a network of Automatic
#' Number Plate Recognition (ANPR) cameras and computed via the
#' anprx python package. Using the anprflows R package, a spatio-temporal
#' window is used to capture relevant traffic and spatial data
#' around the epicentre of the traffic event.
#'
#' @format A list of lists, each containing the following event data:
#' \describe{
#' \item{\code{nodes}}{location ids potentially affected by the incident}
#' \item{\code{flows_l}}{Tibble containing the number of vehicles passing
#' through each of the locations during each time period}
#' \item{\code{flows_od}}{Tibble containing the number, speed statistics
#' and other information of vehicles passing between each pair of locations
#' during each time period}
#' \item{\code{spatial}}{List of spatial data, simple feature dataframes,
#' cropped to the area of interest monitored locations, shortest paths
#' between locations, the enclosing arterial and primary road networks
#'  and nearby amenities}
#' \item{\code{network}}{asymptotic flow network computed over the chosen
#' spatio-temporal window}
#' }
#'
"events"
