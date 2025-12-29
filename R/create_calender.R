#' Create a calender
#'
#' @param dir Directory
#' @param year Year to create a calender for.
#'
#' @author Chantel Wetzel
#' @export
#'
create_calender <- function(
  dir = here::here("doc/figs"),
  year = 2027
) {
  range_dates <- c(paste0(year, "-04-01"), paste0(year, "-09-30"))
  mark_dates <- rep(NA, 365)
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-01-02"),
      as.Date("2027-12-25"),
      by = "7 days"
    )),
    lubridate::yday(seq(
      as.Date("2027-01-03"),
      as.Date("2027-12-26"),
      by = "7 days"
    ))
  )] <- "Weekend"
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-03-03"),
      as.Date("2027-03-10"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-04-06"),
      as.Date("2027-04-12"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-06-16"),
      as.Date("2027-06-22"),
      by = "1 day"
    )) #,
    #lubridate::yday(seq(
    #  as.Date("2027-09-17"),
    #  as.Date("2027-09-22"),
    #  by = "1 day"
    #)),
    #lubridate::yday(seq(
    #  as.Date("2027-11-13"),
    #  as.Date("2027-11-18"),
    #  by = "1 day"
    #))
  )] <- "Council Meeting"
  mark_dates[
    lubridate::yday(c(
      "2027-01-01",
      "2027-01-18",
      "2027-02-15",
      "2027-05-31",
      "2027-06-19",
      "2027-07-05",
      "2027-09-06",
      "2027-10-11",
      "2027-11-11",
      "2027-11-25",
      "2027-12-24"
    ))
  ] <- "Federal Holiday"
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-04-26"),
      as.Date("2027-04-30"),
      by = "1 day"
    ))
  )] <- "Potential STAR Panel - June Council Meeting"
  mark_dates[c(
    lubridate::yday(seq(
      as.Date("2027-05-03"),
      as.Date("2027-05-07"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-05-10"),
      as.Date("2027-05-14"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-05-17"),
      as.Date("2027-05-21"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-06-28"),
      as.Date("2027-07-02"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-07-12"),
      as.Date("2027-07-16"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-07-19"),
      as.Date("2027-07-23"),
      by = "1 day"
    )),
    lubridate::yday(seq(
      as.Date("2027-07-26"),
      as.Date("2027-07-30"),
      by = "1 day"
    ))
  )] <- "Potential STAR Panel - Sept. Council Meeting"
  #mark_dates[c(
  #  lubridate::yday(seq(as.Date("2025-06-02"), as.Date("2025-06-06"), by = "1 day")),
  #  lubridate::yday(seq(as.Date("2025-06-23"), as.Date("2025-06-27"), by = "1 day"))
  #)] <- "STAR Panel (TBD) - Sept. Council Meeting"
  desired_order <- c(
    "Council Meeting",
    "Federal Holiday",
    "STAR Panel - June Council Meeting",
    "STAR Panel - Sept. Council Meeting",
    #"STAR Panel (Possible) - Sept. Council Meeting",
    "Weekend"
  )
  ordered_colors <- c(
    "lightcyan2",
    "pink",
    "darkorchid1",
    "darkolivegreen1",
    #"darkolivegreen4",
    "grey80"
  )[order(desired_order)]
  ordered_colors <-
    nmfspalette::nmfs_palette("regional")(10)

  calendR::calendR(
    year = year,
    title = year,
    subtitle = "STAR Panel Options",
    title.size = 30,
    subtitle.size = 20,
    orientation = c("portrait", "landscape")[1],
    weeknames = c("M", "T", "W", "TH", "F", "S", "S"),
    special.days = mark_dates,
    special.col = PNWColors::pnw_palette("Sailboat", 7)[2:6],
    legend.pos = "bottom",
    mbg.col = PNWColors::pnw_palette("Sailboat", 6)[1], #ordered_colors[1],
    months.col = "white"
  )
  ggplot2::ggsave(
    filename = file.path(dir, paste0(year, "_calendar.png")),
    width = 10,
    height = 10
  )

  calendR::calendR(
    year = year,
    title = year,
    subtitle = "STAR Panel Options",
    title.size = 30,
    subtitle.size = 20,
    orientation = c("portrait", "landscape")[2],
    weeknames = c("M", "T", "W", "TH", "F", "S", "S"),
    special.days = mark_dates,
    special.col = PNWColors::pnw_palette("Sailboat", 7)[2:6],
    legend.pos = "bottom",
    mbg.col = PNWColors::pnw_palette("Sailboat", 6)[1], #ordered_colors[1],
    months.col = "white"
  )
  #ggplot2::ggsave(
  #  filename = file.path(dir, paste0(year, "_calendar_wide.png")),
  #  width = 10,
  #  height = 10
  #)
}
