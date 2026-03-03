#' Create a calender
#'
#' @param dir Directory
#' @param year Year to create a calender for.
#'
#' @author Chantel Wetzel
#' @export
#'
create_calender_3_months <- function(
  dir = here::here("doc/figs"),
  year = 2027
) {
  from <- paste0(year, "-05-01")
  to <- paste0(year, "-07-31")
  n_days <- as.Date(to) - as.Date(from) + 1

  range_dates <- c(from, to)
  mark_dates <- rep(NA, n_days)
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-05-01"),
      as.Date("2027-07-31"),
      by = "7 days"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-05-02"),
      as.Date("2027-07-25"),
      by = "7 days"
    )) -
      lubridate::yday(from) +
      1
  )] <- "Weekend"
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-06-16"),
      as.Date("2027-06-22"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1
  )] <- "Council Meeting"
  mark_dates[
    lubridate::yday(c(
      "2027-05-31",
      "2027-06-19",
      "2027-07-05"
    )) -
      lubridate::yday(from) +
      1
  ] <- "Federal Holiday"
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-05-17"),
      as.Date("2027-05-21"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-05-24"),
      as.Date("2027-05-28"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-06-07"),
      as.Date("2027-06-11"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-06-28"),
      as.Date("2027-07-02"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-07-12"),
      as.Date("2027-07-16"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-07-19"),
      as.Date("2027-07-23"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1,
    lubridate::yday(seq(
      as.Date("2027-07-26"),
      as.Date("2027-07-30"),
      by = "1 day"
    )) -
      lubridate::yday(from) +
      1
  )] <- "Potential STAR Panel - Sept. Council Meeting"

  desired_order <- c(
    "Council Meeting",
    "Federal Holiday",
    "Weekend",
    "STAR Panel - Sept. Council Meeting"
  )
  ordered_colors <- c(
    "lightcyan2",
    "pink",
    "darkorchid1",
    #"darkolivegreen1",
    "grey80"
  )[order(desired_order)]
  ordered_colors <-
    nmfspalette::nmfs_palette("urchin")(length(desired_order))
  ordered_colors <- PNWColors::pnw_palette("Sailboat", 7)[c(2, 3, 6, 4)]

  calendR::calendR(
    year = year,
    title = year,
    subtitle = "STAR Panel Options",
    title.size = 30,
    subtitle.size = 20,
    orientation = c("portrait", "landscape")[1],
    weeknames = c("M", "T", "W", "TH", "F", "S", "S"),
    special.days = mark_dates,
    special.col = ordered_colors,
    legend.pos = "bottom",
    mbg.col = PNWColors::pnw_palette("Sailboat", 6)[1],
    months.col = "white",
    from = "2027-05-01",
    to = "2027-7-31"
  )

  ggplot2::ggsave(
    filename = file.path(dir, paste0(year, "_calendar_3_months.png")),
    width = 20,
    height = 10
  )
}
