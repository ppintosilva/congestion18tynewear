library(tidyverse)
library(lubridate)
library(anprflows)
library(tidygraph)
library(usethis)
library(sf)

# Functions ----

gen_event_data <- function(
  event_id,
  filename,
  start_datetime,
  end_datetime,
  spatial,
  potential_sites,
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

  event <- list(
    "nodes" = node_subset,
    "flows_l" = flows_l,
    "flows_od" = flows_od,
    "spatial" = subspatial,
    "network" = asympt_subnetwork,
    "hparams" = hparams
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
)

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
      gen_event_data(i, filenames[i],
                     metadata$start_datetime[i],
                     metadata$end_datetime[i],
                     spatial,
                     potential_sites[[i]])
  )

usethis::use_data(events, overwrite = TRUE)
