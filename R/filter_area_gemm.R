#' Filter the GEMM data for select sectors
#'
#' @param data Dataframe created by nwfscSurvey::pull_gemm

#'
#' @author Chantel Wetzel
#' @export
#'
filter_area_gemm <- function(
  data
) {
  # black rockfish OR/WA
  # blue/deacon rockfish OR/WA - can only split north and south of 4010 N. lat.
  # cabezon WA
  # china rockfish OR/WA - can only split north and south of 4010 N. lat.
  # copper rockfish OR/WA - can only split north and south of 4010 N. lat.
  # kelp greenling OR/WA
  # quillback rockfish OR/WA

  remove_black <- which(
    data$grouping == "Black rockfish (California)" &
      data$species == "Black Rockfish"
  )
  remove_blue <- which(
    data$grouping == "Minor nearshore rockfish (South of 40°10' N. lat.)" &
      data$species == "Blue/Deacon Rockfish"
  )
  remove_cab <- which(
    data$grouping %in%
      c("Cabezon (California)", "Cabezon/kelp greenling (Oregon)") &
      data$species == "Cabezon"
  )
  remove_china <- which(
    data$grouping == "Minor nearshore rockfish (South of 40°10' N. lat.)" &
      data$species == "China Rockfish"
  )
  remove_copper <- which(
    data$grouping == "Minor nearshore rockfish (South of 40°10' N. lat.)" &
      data$species == "Copper Rockfish"
  )
  remove_kelp <- c(
    which(data$species == "Kelp Greenling (California)"),
    which(
      data$grouping == "Other groundfish" &
        data$species == "Kelp Greenling"
    ),
    which(
      data$grouping == "Cabezon/kelp greenling (Oregon)" &
        data$species == "Kelp Greenling"
    )
  )
  remove_quill <-
    which(
      data$grouping == "Minor nearshore rockfish (South of 40°10' N. lat.)" &
        data$species == "Quillback Rockfish (California)"
    )
  remove_all <- c(
    -remove_black,
    -remove_blue,
    -remove_cab,
    -remove_china,
    -remove_copper,
    -remove_kelp,
    -remove_quill
  )
  data_filtered <- data[remove_all, ]
  return(data_filtered)
}
