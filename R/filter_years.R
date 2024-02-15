
filter_years <- function(data, years){

 year_column <-  c("YEAR", "PACFIN_YEAR", "RECFIN_YEAR", "SPEX_YEAR")[c("YEAR", "PACFIN_YEAR", "RECFIN_YEAR", "SPEX_YEAR") %in%  colnames(data)]
 data_filtered <- data[data[, year_column] %in% years, ]
 return(data_filtered)
  
}