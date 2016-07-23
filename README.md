# **waclr**

[![Build Status](https://travis-ci.org/skgrange/waclr.svg?branch=master)](https://travis-ci.org/skgrange/waclr)

**waclr** is an R package for doing things at the Wolfson Atmospheric Chemistry Laboratory (WACL). 

## Installation

To install the development version the [**devtools**](https://github.com/hadley/devtools) package will need to be installed first. Then:

```
# Install waclr
devtools::install_github("skgrange/waclr")
```

## Uses

**waclr** can be used to access air quality monitoring data which are maintained internally. For example, hourly monitoring data for a site which has the goal of capturing fracking activities in North Yorkshire can be accessed. The first step is to find what the site code is. To get the site code, and other metadata of facilities use `get_wacl_sites`. 

```
# Load package
library(dplyr)
library(waclr)

# Get metadata for sites which are serviced
data_sites <- get_wacl_sites()


# Print site names and region
data_sites %>% 
  select(site, 
         site_name,
         region)

  site            site_name          region
1 kirb      Kirby Misperton north_yorkshire
2 litp Little Plumpton Farm      lancashire
```

The site which is desired is Kirby Misperton, site code `kirb`. The site code is used in `get_wacl_data`:

```
# Get data for two years for Kirby Misperton
data_kirb <- get_wacl_data(site = "kirb", year = 2016:2017, period = "hour")
```

Analysis can now be done with tools such as [**openair**](https://github.com/davidcarslaw/openair). 
