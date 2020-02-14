
# congestion18tynewear

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/ppintosilva/congestion18tynewear.svg?branch=master)](https://travis-ci.org/ppintosilva/congestion18tynewear)
<!-- badges: end -->

This package contains data of several events that affected 
traffic flow in the region of Tyne and Wear in the year 2018:

- `metadata` contains information about the events as tweeted by the regional
[Urban Traffic Management & Control facility](https://twitter.com/NELiveTraffic).
- `events` contains the following data for each event:
  - traffic `flow` captured around the epicentre of the traffic event,
  within a time window of several hours before and after the incident.
  - `spatial` features cropped to the area of interest.
  Includes data about monitored locations, shortest paths between
  locations, the enclosing primary (A,B and C roads) and arterial road networks
  and nearby amenities.
  - a `network` capturing the relationships between flows.
  
The main goal of this package is to provide resources to study and profile
traffic congestion under different urban scenarios, using a type of data
which is often not readily available to researchers but whose underlying 
technology is becoming more widespread in developed cities
(Automatic Number Plate Recognition).

The data are packaged so that it's ready and easy to work with using the
[anprflows](https://github.com/ppintosilva/anprflows) package. 
Refer to vignettes for examples on to visualise and use the data.

## A note on traffic flow data

Flow data refers to origin-destination (OD) traffic flows between pairs of
locations in the road network. This includes the number, and speed statistics 
of vehicles passing between each pair of locations during each time period.
At these locations,
one or more Automatic Number Plate Recognition (ANPR) cameras have been deployed,
so that individual and aggregate travel times can be recorded and inform
traffic bodies of real-time traffic state and network performance.

Flow data is derived from raw ANPR data – a table containing the columns
`vehicle_id | location | timestamp` – using the
[anprx](https://github.com/ppintosilva/anprx) python package.
A link to the associated research paper and underlying methodology is hopefully
coming soon. 
These can then be further spatially cropped, visualised and analysed using the
[anprflows](https://github.com/ppintosilva/anprflows).

## Installation

The package is not yet available in CRAN.

You can install the development version from Github:

``` r
devtools::install_github("ppintosilva/congestion18tynewear")
```
