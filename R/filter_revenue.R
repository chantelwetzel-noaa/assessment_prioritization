#' Filter out and identify tribal and non-tribal records
#'
#' @param data PacFIN CompFT data table
#' @param type Default NULL. To filter and mark tribal records type = "tribal"
#'
#' @author Chantel Wetzel
#' @export
#'
filter_revenue <- function(data, type = NULL){
  if(type == "tribal") {
    fleet_code <- "TI"
  } else {
    fleet_code <- unique(data$FLEET_CODE)[unique(data$FLEET_CODE) != "TI"]
  }
  
  data_filtered <- data[data[, "FLEET_CODE"] %in% fleet_code, ]
  return(data_filtered)
}