library(tidyverse)
library(lubridate)
library(anprflows)
library(tidygraph)
library(usethis)
library(sf)

# To be defined when adding new data ----

# Event case by case filtering functions
location_filter_functions <- list(
  "2018-02-21" = function(x)
    filter(x, !!quo(ref) == "A184" & !!quo(direction) == "W")
  ,
  "2018-03-16" = function(x)
    filter(x, !!quo(ref) == "B1318" & !!quo(direction) == "S")
  ,
  "2018-05-04" = function(x)
    filter(x, !!quo(ref) == "A690" & str_detect(!!quo(address), "Durham"))
  ,
  "2018-08-14" = function(x)
    filter(x, str_detect(!!quo(address), "Angel of the North"))
  ,
  "2018-10-08" = function(x)
    filter(x, !!quo(ref) == "B1318" & !!quo(direction) == "N")
  ,
  "2018-11-01" = function(x)
    filter(x, !!quo(ref) == "A1018" & str_detect(!!quo(address), "Sunderland"))
  ,
  "2018-11-25" = function(x)
    filter(x, (!!quo(ref) == "B1318" | !!quo(ref) == "B1307") &
             !!quo(direction) == "S")
  #
  # @ADD function for new event here
  #
)

# approximate incident location
incident_points <- tibble::tribble(
  ~lon, ~lat,
  -1.537728, 54.946661,
  -1.623651, 55.030819,
  -1.421769, 54.885849,
  -1.584383, 54.911493,
  -1.621560, 55.014966,
  -1.382897, 54.909823,
  -1.612634, 54.979322
  #
  # @ADD approximate incident/congestion point for new event here
  #
) %>%
  dplyr::mutate(
    geometry = purrr::pmap(list(lon,lat),
                           function(x,y) sf::st_point(c(x,y)))
  ) %>%
  tibble::rowid_to_column(var = "id") %>%
  dplyr::select(id, geometry)


# Functions ----

gen_event_data <- function(
  event_id,
  filename,
  start_datetime,
  end_datetime,
  spatial,
  potential_sites,
  incident_point,
  hparams = list(
    "rate_o" = .1,
    "rate_d" = .1,
    "bbox_margin" = c(-500,-500,500,500)
  )
) {
  # week number
  flows <- read_data(filename)

  print(paste0("Processing event ", event_id, "..."))

  asympt_flows_l <-
    flows %>% anprflows::get_flows_l(by_period = FALSE)

  asympt_flows_od <-
    flows %>% anprflows::get_flows_od(asympt_flows_l, by_period = FALSE)

  asympt_network <- anprflows::flow_network(
    asympt_flows_od,
    spurious_if_below =
      c("rate_o" = hparams[["rate_o"]], "rate_d" = hparams[["rate_d"]]))

  asympt_subnetwork <- anprflows::get_neighbors(
    network = asympt_network,
    nodes = potential_sites$id %>% as.character()
  )

  node_subset <-
    asympt_subnetwork %>%
    tidygraph::activate(nodes) %>%
    as_tibble() %>%
    pull(name) %>%
    as.character()

  flows_subset <-
    flows %>%
    filter(t > start_datetime & t < end_datetime) %>%
    filter(
      o %in% node_subset,
      d %in% node_subset
    )

  flows_l <- flows_subset %>% anprflows::get_flows_l()
  flows_od <- flows_subset %>% anprflows::get_flows_od(flows_l)

  subspatial <-
    anprflows::crop_spatial(
      flows_od,
      spatial,
      bbox_margin = hparams[["bbox_margin"]]
    )

  incident_point <-
    incident_point %>%
    sf::st_as_sf()

  st_crs(incident_point) <- 4326

  # project point to utm
  incident_point <- incident_point %>%
    sf::st_transform(crs = sf::st_crs(spatial$locations))

  event <- list(
    "nodes" = node_subset,
    "flows_l" = flows_l,
    "flows_od" = flows_od,
    "spatial" = subspatial,
    "network" = asympt_subnetwork,
    "hparams" = hparams,
    "incident" = incident_point
  )

  return(event)
}

read_data <- function(
  filename
) {
  print(paste0("Reading event data for input file: ", filename))

  flows <- anprflows::read_flows_csv(filename, skip = 1)

  return(flows)
}

get_potential_sites <- function(spatial, filter_function) {
  spatial$locations %>%
    as_tibble %>%
    filter_function %>%
    sf::st_as_sf()
}

# Main loop ----

# local directory where spatial and pipeline data can be found
# FUTURE #TODO -> download from zenodo the necessary files
metadata <- read_csv("data-raw/metadata.csv")

dataset_dir <- "pipeline-data/"
filenames <-
  paste0(
    dataset_dir,
    "flows/fifteenmin/flows_15min_anpr18_week",
    sapply(metadata$start_datetime, lubridate::week),
    ".csv"
  )

spatial <- read_rds(paste0(dataset_dir, "spatial.rds"))

hparams = list(
  "rate_o" = .1,
  "rate_d" = .1,
  "bbox_margin" = c(-500,-500,500,500)
)

potential_sites <-
  lapply(metadata$date %>% as.character(),
         function(d) get_potential_sites(
           spatial,
           location_filter_functions[[d]]))

events <-
  lapply(
    metadata$id,
    function(i)
      gen_event_data(event_id = i,
                     filename = filenames[i],
                     start_datetime = metadata$start_datetime[i],
                     end_datetime = metadata$end_datetime[i],
                     spatial = spatial,
                     potential_sites = potential_sites[[i]],
                     incident_point = filter(incident_points, id == i))
  )

usethis::use_data(events, overwrite = TRUE)
