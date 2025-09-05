#' Standardize species names
#' 
#' Function to format species names to add cryptic species names is 
#' missing and to apply the upper case for the first letter for each
#' species name.
#' 
#' @param x A factor data frame that contains species names to be renamed.
#'
#' @returns The factor data frame with the species renamed 
#' @author Chantel Wetzel
#' @export
#' @examples 
#' \dontrun{ mort_adj <- format_species_names(x = mortality) }
#' 
format_species_names <- function(x){
  
  x_formatted <- x |>
    dplyr::mutate(
      Species = dplyr::case_when(
        Species %in% c("rougheye rockfish", "blackspotted rockfish", "rougheye and blackspotted rockfish", "rougheye and black spotted rockfish", "rougheye/blackspotted rockfish") ~ "Rougheye/Blackspotted rockfish",
        Species %in% c("vermilion rockfish", "sunset rockfish", "vermilion and sunset rockfish", "vermilion/sunset rockfish") ~ "vermilion/Sunset rockfish",
        Species %in% c("gopher rockfish", "black and yellow rockfish", "gopher and black and yellow rockfish", 
                       "gopher/black and yellow rockfish") ~ "gopher/Black and Yellow rockfish",
        Species %in% c("blue rockfish", "deacon rockfish", "blue and deacon rockfish", "blue/deacon rockfish") ~ "blue/Deacon rockfish",
        .default = Species
      )
    ) |>
    dplyr::mutate(
      Species = paste0(stringr::str_to_upper(stringr::str_sub(Species, 1, 1)), stringr::str_sub(Species, 2, -1))
    )
  return(x_formatted)
}

