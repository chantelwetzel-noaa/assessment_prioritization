
filter_revenue <- function(data, type){
  
  if(type == "tribal") {
    fleet_code <- "TI"
  } else {
    fleet_code <- unique(data$FLEET_CODE)[unique(data$FLEET_CODE) != "TI"]
  }
  
  data_filtered <- data[data[, "FLEET_CODE"] %in% fleet_code, ]
  return(data_filtered)
}