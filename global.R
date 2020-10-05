library(dplyr)
library(ISOcodes)
library(stringr)
library(leaflet)

read_dataset <- function() { 
  return(read.csv("./data/ships_dataset.csv"))
  }

SHIPS_DATA <- read_dataset()


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


get_country_name <- function(ship_id) { 
  assertthat::is.number(as.numeric(ship_id))  
  country_code <- get_country_code_by_ship_id(ship_id)
  if (country_code == 'NaN') { 
    return('Unknown')
  }
  country <- ISOcodes::ISO_3166_1 %>% 
    filter(Alpha_2 == country_code)
  return(country$Name)
  }


get_country_code_by_ship_id <- function(ship_id) { 
  assertthat::is.number(as.numeric(ship_id))  
  if (!is.na(ship_id)) {
    country_code <- SHIPS_DATA %>% 
                      filter(SHIP_ID == ship_id)
    return(country_code$FLAG[1])  
  } else { 
    return('NaN')  
  }
}


generate_marinetraffic_link <- function(ship_id) {
  assertthat::is.number(as.numeric(ship_id))  
  url <- sprintf('https://www.marinetraffic.com/en/ais/details/ships/shipid:%s', ship_id)
  return(url)
  }


get_destination_port <- function(ship_id) { 
  assertthat::is.number(as.numeric(ship_id))  
  data <- SHIPS_DATA %>% 
            filter(SHIP_ID == ship_id)
  port <- data$port[1]
  port <- str_to_title(tolower(port))
  return(port)
  } 


get_distance_by_id <- function(ship_id) { 
  assertthat::is.number(as.numeric(ship_id))  
  if (!is.na(ship_id)) {
    data <- SHIPS_DATA %>% 
      filter(SHIP_ID == ship_id)
    distance <- data$position
    distance <- round(as.numeric(strsplit(as.character(distance), ' ')[[1]][5]), 2)
    return(distance)
  }
  return('')
  }


### Leaflet ICON

shipIcon <- makeIcon(
  "./static/svg/coast-guard-4130567.svg",
  iconWidth = 38, iconHeight = 95,
  iconAnchorX = 0, iconAnchorY = 0
)
### Assumption 1. SHIP_ID is a unique number for a unique SHIP
### Assumption 2. SHIP_ID is one-to-one to SHIPNAME 
### NOTE: SHIP_ID is not unique here because we have different names for a unique ID so for the purpose of
### the task and not knowing for sure which name is the correct for a given ID I've kept both.  
  
