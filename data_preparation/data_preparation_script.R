source('./data_preparation_helpers.R')

# NOTES
# 1. Dataset has been converted to the feather format, this step has been omitted in the code

# Reading data
SHIPS_DATA <- load_data_feather()
SHIPS_DATA <- SHIPS_DATA[1:10000,]
SHIPS_DATA <- remove_unique_observations(SHIPS_DATA)

# Getting the processed dataset
# 1. Group by id (assuming one unique id per ship)
# 2. Convert the datetime string to a tz object and later to a timestamp
# 3. Sort the timestamp in ascending order (latest observation at the end of the dataset)
# 4. Get the position of the maximum distance for each step in the subsetted dataset
# 5. Keep only the unique rows and some selected columns
ships_dataset <- SHIPS_DATA %>% 
  dplyr::group_by(SHIP_ID) %>%
  dplyr::group_modify(~ {
    .x %>%
      dplyr::mutate(parsed_date = unlist(purrr::map(.x$DATETIME, parse_date)))
  }) %>%
  dplyr::arrange(parsed_date) %>%
  dplyr::group_modify(~ {
    .x %>%
      dplyr::mutate(position = get_max_distance_positions(.x))
  }) %>% 
  dplyr::select(SHIP_ID, ship_type, SHIPNAME, port, FLAG, position) %>% 
  dplyr::distinct()

## We'll end up with more than one unique ship id but I'm not taking any decision here to discard any of 
# the information since that I don't have any criteria to know which is valid with the information and time
# that I have
# Write to for later use (Dataset is much smaller now, so I prefer to use a base R function to do it)
write.csv(ships_dataset, "ships_dataset.csv")



# test <- load_data_feather()
# df_test <- test[1:10000,] 
