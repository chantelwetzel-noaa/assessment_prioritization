filter_gemm <- function(data, sector = c("California Recreational", "Oregon Recreational", "Washington Recreational")){
  data_filtered <- data[data$sector %in% sector, ]
  return(data_filtered)
}