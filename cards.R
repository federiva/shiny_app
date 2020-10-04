
get_card <- function(header, meta, description) { 
  card(div(class = "content", 
           div(class = "header", header),
           div(class = "meta", meta),
           div(class = "description", description)
           )
       )
}
