library(dplyr)
library(ISOcodes)
library(stringr)

read_dataset <- function() { 
  return(read.csv("ships_dataset.csv"))
  }

SHIPS_DATA <- read_dataset()

TYPES_CHOICES <- sort(unique(SHIPS_DATA$ship_type), decreasing = TRUE)


filter_ships_by_type <- function(ship_type) { 
  return(SHIPS_DATA %>% 
           filter(ship_type == ship_type) %>%
           distinct(SHIP_ID, SHIPNAME) %>% 
           pull(SHIPNAME))
}

get_types_names_pairs <- function() { 
  return( SHIPS_DATA %>%
            distinct(SHIPNAME, ship_type))
}


flatten_datetimes_list <- function(list_in) { 
  return(do.call("c", list_in))
}

get_country_name <- function(ship_id) { 
  country_code <- get_country_code_by_ship_id(ship_id)
  country <- ISOcodes::ISO_3166_1 %>% 
    filter(Alpha_2 == country_code)
  return(country$Name)
  }

get_country_code_by_ship_id <- function(ship_id) { 
  country_code <- SHIPS_DATA %>% 
                    filter(SHIP_ID == ship_id)
  return(country_code$FLAG)
  }


generate_marinetraffic_link <- function(ship_id) { 
  url <- sprintf('https://www.marinetraffic.com/en/ais/details/ships/shipid:%s', ship_id)
  return(url)
  }


get_destination_port <- function(ship_id) { 
  data <- SHIPS_DATA %>% 
            filter(SHIP_ID == ship_id)
  port <- data$port
  port <- str_to_title(tolower(port))
  return(port)
  } 

get_distance_by_id <- function(ship_id) { 
  data <- SHIPS_DATA %>% 
    filter(SHIP_ID == ship_id)
  distance <- data$position
  distance <- round(as.numeric(strsplit(as.character(distance), ' ')[[1]][5]), 2)
  return(distance)
  }


### Leaflet ICON

shipIcon <- makeIcon(
  "./appsilon_home_test/static/svg/coast-guard-4130567.svg",
  iconWidth = 38, iconHeight = 95,
  iconAnchorX = 0, iconAnchorY = 0
)
### Assumption 1. SHIP_ID is a unique number for a unique SHIP
### Assumption 2. SHIP_ID is one-to-one to SHIPNAME 
### NOTE: SHIP_ID is not unique here because we have different names for a unique ID so for the purpose of
  
  
