# Shiny App - SHIPS
This readme has a summary of the code, its files and a short rationale of the functions and workflow used. 

## App's file structure

    .  
    ├──── data  
    │     └──── ships_dataset.csv  
    |     └──── ships_feather.tar.xz
    ├──── data_preparation  
    │     ├──── data_preparation_helpers.R  
    │     └──── data_preparation_script.R  
    ├──── modules  
    |     └──── dropdown  
    |           └──── dropdown_ui.R
    ├──── static
    |     └──── svg
    |           └──── coast-guard-4130567.svg 
    ├──── app.R  
    ├──── cards.R  
    └──── global.R  

## Data Preparation
  
**SUMMARY**  
* `feather_data.feather` -> `data_preparation_script.R` -> `ships_dataset.csv`  
  
This has been done to reduce the dataset size in order to improve loading time and speed of the app. This means that all of the calculation and data processing has been done here.  
  
**ASSUMPTIONS**  
1. SHIP_ID is unique, this means for example that a join of SHIP_ID:SHIPNAME will only result in one row.  
  1.1. This assumption didn't hold.  
    1.1.1. The duplicated data was kept, so we are listing more than one shipname per ship_id, nevertheless the distance calculation is the same in these cases. The reason for doing this is that I don't know which name is the correct one, and, this is just a test.  
  
**NOTES**  
1. The original dataset was converted to the feather format. The feather file is compressed into the `ships_feather.tar.xz` file. 
1. DATETIME column was converted to a posix valid datetime object and later converted to a numeric timestamp in order to sort the subsetted dataset using this key.
1. The maximum distance between two consecutive datapoints for a given ship (SHIP_ID) was calculated for all of the ships with the `calculateDistances` fn, if this result has more than one occurrence in the dataset then we got the last index (`get_max_distances`) 
1. SHIPS_IDs with only one occurrence in the dataset were been discarded (using `remove_unique_observations`) 
1. The final dataset has the SHIP_ID, ship_type, SHIPNAME, port, FLAG and position columns.  
  1.1. The only added column is the position which is a character column with the following format (latitude_1 latitde_2 longitude_1 longitude_2 distance_in_meters) Maybe I could've used a JSON here.
1. The workflow of the data preparation that will end with the `ships_dataset.csv` file is pretty self-explanatory I think and maybe better than this explanation. It's located in the `data_preparation_script.R`  


 ## Global functions
   
 **SUMMARY**
 * Contains the global functions used in the `app.R` file  
 * Mostly are getter functions with a few exceptions (`shipIcon`, `generate_marinetraffic_link`, `read_dataset` and `filter_ships_by_type`)
