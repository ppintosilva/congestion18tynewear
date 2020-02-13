## code to prepare `event-metadata` dataset goes here
library(tidyverse)
library(lubridate)
library(usethis)

tweet_links <- paste0("https://twitter.com/NELiveTraffic/status/",
                      c(
                        "966227277393682433",
                        "992304917493645312",
                        "1049349986427834368",
                        "1058043340170637313",
                        "1066692134139568128",
                        "986633195352416256",
                        "1029381970248298497"
                      ))

event_ids <- 1:length(tweet_links)

dates <- c(
  "2018-02-21",
  "2018-05-04",
  "2018-10-08",
  "2018-11-01",
  "2018-11-25",
  "2018-03-16",
  "2018-08-14"
)

event_time <- c(
  "08:25",
  "08:28",
  "18:25",
  "17:07",
  "13:56",
  "16:49",
  "15:59"
)

start_times <- c(
  "04:00",
  "04:00",
  "12:00",
  "12:00",
  "06:00",
  "12:00",
  "12:00"
)

end_times <- c(
  "12:00",
  "12:00",
  "22:00",
  "22:00",
  "20:00",
  "20:00",
  "20:00"
)

tweets <- c(
  paste0(
    "BROKEN DOWN VEHICLE",
    "A184 Felling Bypass westbound after A195 Lingey Lane #Wardley.",
    "A Land Rover is blocking lane 1 awaiting recovery, police on-scene.",
    "Expect heavy congestion.",
    sep = " "),
  paste0(
    "A690 Durham Road, traffic starting to break up after earlier",
    "congestion between the North Moor Lane roundabout and the junction",
    "with B1405 Springwell Road  in #Sunderland",
    sep = " "),
  paste0(
    "CONGESTION",
    "B1318 Great North Road northbound through #Gosforth from A189",
    "Blue House to Broadway roundabout is 34 mins.",
    sep = " "),
  paste0(
    "CONGESTION",
    "A1018 Wearmouth Bridge & North Bridge Street northbound",
    "in #Sunderland this evening.",
    sep = " "),
  paste0(
    "B1318 Barras Bridge & B1307 Percy Street southbound #Newcastle city",
    "centre into Eldon Square car park. ",
    sep = " "),
  paste0(
    "B1318 Great North Road, heavy slow moving traffic moving southbound",
    "into #Gosforth with congestion at the A1 - A1056 merge #Newcastle, 4:50pm",
    sep = " "),
  paste0(
    "Police are attending an overturned vehicle on the A1 WBP southbound ",
    "near junction 66 Angel of The North #Gateshead.",
    "CLEARED",
    "Previous overturned vehicle A1 Southbound J66 A167",
    "#AngeloftheNorth - J65 A194(M) #Washington now removed.",
    "All lanes open although there is still congestion which will take ",
    "time to clear.",
    sep = " ")
)

metadata <-
  tibble(
    id = event_ids,
    date = lubridate::ymd(dates),
    start_datetime = lubridate::ymd_hm(paste0(dates,start_times)),
    end_datetime = lubridate::ymd_hm(paste0(dates,end_times)),
    event_time = lubridate::hm(event_time),
    tweet = tweets,
    link = tweet_links
  )


write_csv(metadata, "data-raw/metadata.csv")

usethis::use_data(metadata, overwrite = TRUE)
