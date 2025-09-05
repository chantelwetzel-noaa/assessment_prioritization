#' Combine management group to tables based on species names
#' 
#' Function to join the given table with the table that has the species management
#' groups. Replaces underscores in column names with spaces.
#'
#' @param x A factor dataframe
#' @param man_groups A dataframe containing the species management groups
#' @returns Joined dataframe with edited column names
#' @author Chantel Wetzel
#' @export
format_table <- function(
  x, 
  man_groups) {
  cap_man <- format_species_names(x = man_groups)
  joined_df <- dplyr::left_join(x, cap_man, by = "Species") |>
    dplyr::rename_with(~gsub("_", " ", .x))
  return(joined_df)
}