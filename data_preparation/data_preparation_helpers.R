library(dplyr)
library(geosphere)
library(purrr)

# Constants
FILE_PATH_FEATHER = '../data/ships.feather'
DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"


load_data_feather <- function() {
  return(feather::read_feather(FILE_PATH_FEATHER))
}

calculateDistances <- function(df_in) {
  ## Distances are calculated between two matrixes
  ##   This means that the first calculated distance is the distance for the first and second point in the
  ## dataset
  m1_lon <- df_in$LON[1:length(df_in$LON)-1]
  m1_lat <- df_in$LAT[1:length(df_in$LAT)-1]
  assertthat::assert_that({length(m1_lon) == length(m1_lat)},msg = 'ValueError: Vectors m_1lon and m1_lat must be of the same lenght')
  m_1 <- cbind(m1_lon,m1_lat)
  
  m2_lon <- df_in$LON[2:length(df_in$LON)]
  m2_lat <- df_in$LAT[2:length(df_in$LAT)]
  assertthat::assert_that({length(m2_lon) == length(m2_lat)},msg = 'ValueError: Vectors m_2lon and m2_lat must be of the same lenght')
  m_2 <- cbind(m2_lon,m2_lat)
  
  distances <- geosphere::distGeo(m_1,m_2)
  return(distances)
}


get_max_distances <- function(distances) { 
  ### Returns a named list with the distance and the indexes for which the max value was found
  ### An index 1 corresponds to the rows 1 and 2 (n and n+1) in the original dataframe
  max_distance = max(distances)
  indexes = which(distances == max_distance)
  if (length(indexes) > 1) { 
    indexes = max(indexes) # The last index - We have sorted the timestamps in ascending order
  }
  return(list('distance'=max_distance, 'indexes'=indexes))
}


get_lat_lon <- function(df, max_distance_index) { 
  return( 
    list('lat_1' = df[max_distance_index,]$LAT,
         'lat_2' = df[max_distance_index+1,]$LAT,
         'lon_1' = df[max_distance_index,]$LON,
         'lon_2' = df[max_distance_index+1,]$LON)
  )
} 


parse_date <- function(datetime_string) { 
  return(as.numeric(strptime(datetime_string, DATETIME_FORMAT)))
}


add_datetime_column <- function(df) { 
  df$d_as_datetime <- purrr:map_dbl(df$DATETIME, parse_date)
  return(df)
}


get_max_distance_positions <- function(dataset) { 
  # Main function to get the locations 
  result <- tryCatch({ 
    distances <- calculateDistances(dataset)
    max_distances <- get_max_distances(distances)
    locations <- get_lat_lon(dataset, max_distances$indexes)
    return(paste(locations$lat_1, locations$lon_1, locations$lat_2, locations$lon_2, max_distances$distance))
  }, 
  error = function(err) { 
    print(err)
    return(paste('NA', 'NA', 'NA', 'NA'))
  })
  return(result)
}


remove_unique_observations <- function(dataset) { 
  # Removes rows for which its SHIP_ID its occurring only once in the dataset
  result <- table(dataset$SHIP_ID)
  ids_to_remove <- names(result[result<=1])
  for (id_ship in ids_to_remove) { 
    print(id_ship)
    dataset <- dataset %>% 
      dplyr::filter(SHIP_ID!=id_ship)
  }
  
  return(dataset)
}

