library(shiny)
library(shiny.semantic)
library(leaflet)
source('./global.R')
source('./modules/dropdown/dropdown_ui.R')
source('./cards.R')



ui <- semanticPage(
  grid(grid_template(default = list(areas = rbind(c("header", "header", "header"), 
                                                  c("dropdown", "blank", "blank"), 
                                                  c("dropdown", "blank", "blank"), 
                                                  c("card1", "card2", "card3"),
                                                  c('map'), 
                                                  c('distance_traveled')
                                                  ),
                                    rows_height = c("50px", "100px", "100px", 'auto'), 
                                    cols_width = c("auto", "auto", "auto"))), 
       container_style = "border: 1px solid #f00; padding:10px", 
       area_styles = list(header = "background: #0099f9; padding: 10px",
                          dropdown = "margin-left: 15px; margin-top: 20px; width:50%;",
                          distance_traveled = 'border:solid; border-color:gray; width=50%; text-align:center;'
                          ),
       header = h1(class = "ui header", "Ships - Appsilon"), 
       dropdown = dropdownUI('ships_selector', get_types_names_pairs()),
       blank='',
       card1= get_card(header='Destination Port', 
                       meta= '', 
                       description=textOutput('destination_port')), 
       card2= get_card(header = 'Country of Origin', 
                       meta = '', 
                       description = textOutput('country_of_origin')),
       card3= get_card(header='Additional information', 
                       meta='', 
                       description=a(textOutput('link_marine'), )), 
       distance_traveled=verbatimTextOutput('distance_traveled'),
       map=leafletOutput("ships_map")) 
  
)

server <- function(input, output, session) {
  values <- dropdownServer('ships_selector')
  output$distance_traveled <- renderText({sprintf('Distance traveled (meters): %s', get_distance_by_id(values$val))})
  output$country_of_origin <- renderText({get_country_name(values$val)})
  output$link_marine <- renderText({generate_marinetraffic_link(values$val)})
  output$destination_port <- renderText({get_destination_port(values$val)})
  output$ships_map <- renderLeaflet({
    validate(
      need(values$val != 'NULL', FALSE)
    )
    leaflet(data=values$locations) %>% 
      addTiles() %>%
      addPolylines(lng = ~lon, lat = ~lat, weight = 2, color='orange') %>%
      addMarkers(~lon, ~lat, icon=shipIcon)
  })
}



shinyApp(ui, server)
    
