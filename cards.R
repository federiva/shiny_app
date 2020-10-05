
get_card <- function(header, meta, description, link='') { 
  card(div(class = "content", 
           div(class = "header", header),
           div(class = "meta", meta),
           div(class = "description", description),
           link
           )
       )
}
