#' Calculate tiess within ranks.
#' 
#' @param data Dataframe
#' @param column_name Column name to determine the ties for
#'
#' @author Chantel Wetzel
#' @export
#' 
#'
calculate_ties <- function(
  data, 
  column_name = "Rank"){
  x <- 1
  for(i in sort(unique(data[, column_name]), decreasing = TRUE)) {
    ties <- which(data[, column_name] == i)
    if(length(ties) > 0) {
      data[, i][ties] <- x
    }
    x <- x + length(ties)
  }
  return(data)
}