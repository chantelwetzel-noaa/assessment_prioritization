#'
#' 
#' 
#' 
#'
#' @param dir Directory of saved factor file
#' @param mov_to Directory of the shiny app
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' 
#'
move_files_to_sap <- function(
  dir = here::here("data-processed"), 
  move_to = "C:/Users/Chantel.Wetzel/Documents/GitHub/wcgfishSAP/tables"){
  
  
  file.copy(from = file.path(dir, "1_fishing_mortality.csv"),
            to = file.path(move_to, "1_fishing_mortality.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "2_commercial_revenue.csv"),
            to = file.path(move_to, "2_commercial_revenue.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "3_tribal_revenue.csv"),
            to = file.path(move_to, "3_tribal_revenue.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "4_recreational_importance.csv"),
            to = file.path(move_to, "4_recreational_importance.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "5_ecosystem.csv"),
            to = file.path(move_to, "5_ecosystem.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "6_stock_status.csv"),
            to = file.path(move_to, "6_stock_status.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "7_assessment_frequency.csv"),
            to = file.path(move_to, "7_assessment_frequency.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "8_constituent_demand.csv"),
            to = file.path(move_to, "8_constituent_demand.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "9_new_information.csv"),
            to = file.path(move_to, "9_new_information.csv"), overwrite = TRUE)
  file.copy(from = file.path(dir, "10_rebuilding.csv"), 
            to = file.path(move_to, "10_rebuilding.csv"), overwrite = TRUE)
  
}