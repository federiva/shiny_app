parse_location <- function(row_data) { 
  splitted <- strsplit(as.character(row_data$position), ' ')[[1]]
  lat_1 <- as.numeric(splitted[1])
  lon_1 <- as.numeric(splitted[2])
  lat_2 <- as.numeric(splitted[3])
  lon_2 <- as.numeric(splitted[4])
  return(tibble('lat'= c(lat_1, lat_2), 'lon'= c(lon_1, lon_2)))
}


get_locations_dataset <- function(ship_id) { 
  return ( SHIPS_DATA %>% 
             filter(SHIP_ID == ship_id) %>% 
             parse_location()
  )
}


get_unique_types <- function(pairs_names_types_df) { 
  return( pairs_names_types_df %>% 
            distinct(ship_type)) %>% 
            arrange
  }

get_ship_names_by_type <- function(ship_type_in) { 
  return(SHIPS_DATA %>% 
           filter(ship_type == ship_type_in) %>%
           distinct(SHIP_ID, .keep_all = T) %>% 
           arrange(SHIPNAME) %>%
           select(SHIPNAME, SHIP_ID)
  )
}

dropdownUI <- function(id, values) { 
  require(shiny)
  require(shiny.semantic)
  
  ns <- NS(id)
  choices = get_unique_types(values)$ship_type
  selected = choices[1]
  tagList(
    selectInput(inputId = ns("ship_type"), 
                label = 'Select a ship type', 
                choices = choices, 
                selected = selected),
    
   selectInput(inputId = ns("ship_name"), 
               label = 'Select a ship', 
               choices = list(), 
               choices_value = list())
  )
  
}

dropdownServer <- function(id) { 
  moduleServer(
    id, 
    function(input, output, session) {
      dat <- reactiveValues()
      observeEvent(input$ship_type, {
        validate(
          need(input$ship_type, FALSE)
        )
        data_choices <- get_ship_names_by_type(input$ship_type)
        choices_value <- data_choices$SHIP_ID
        choices <- data_choices$SHIPNAME
        shiny.semantic::update_dropdown_input(session,
                          'ship_name', 
                          choices = choices, 
                          choices_value = choices_value)
      })
      
      observe({dat$val <- ifelse(input$ship_name == 'NULL', NA, input$ship_name)})
      observe({
        req(input$ship_name)
        validate(need(dat$val != 'NULL', FALSE))
        dat$locations <- get_locations_dataset(input$ship_name)
        })
      return(dat) 
    }
  )
}



