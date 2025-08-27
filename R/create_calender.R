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
  year = 2025){
  
  range_dates <- c(paste0(year, "-04-01"), paste0(year, "-09-30")) 
  mark_dates <- rep(NA, 365)
  mark_dates[c(
    lubridate::yday(seq(as.Date("2025-01-04"), as.Date("2025-12-27"), by = "7 days")),
    lubridate::yday(seq(as.Date("2025-01-05"), as.Date("2025-12-28"), by = "7 days"))  
  )] <- "Weekend"
  mark_dates[c(
    lubridate::yday(seq(as.Date("2025-03-05"), as.Date("2025-03-11"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-04-09"), as.Date("2025-04-15"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-06-12"), as.Date("2025-06-18"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-09-18"), as.Date("2025-09-24"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-11-13"), as.Date("2025-11-19"), by = "1 day"))
  )] <- "Council Meeting"
  mark_dates[
    lubridate::yday(c("2025-01-01", "2025-01-20", "2025-02-17", "2025-05-26", "2025-06-19", "2025-07-04", "2025-09-01", "2025-10-13", "2025-11-11", "2025-11-27", "2025-12-25"))
  ] <- "Federal Holiday"
  mark_dates[c(
    lubridate::yday(seq(as.Date("2025-04-28"), as.Date("2025-05-02"), by = "1 day"))
  )] <- "Potential STAR Panel - June Council Meeting"
  mark_dates[c(
    lubridate::yday(seq(as.Date("2025-05-05"), as.Date("2025-05-09"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-05-12"), as.Date("2025-05-16"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-05-19"), as.Date("2025-05-23"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-06-02"), as.Date("2025-06-06"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-06-23"), as.Date("2025-06-27"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-07-07"), as.Date("2025-07-11"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-07-14"), as.Date("2025-07-18"), by = "1 day")),
    lubridate::yday(seq(as.Date("2025-07-21"), as.Date("2025-07-25"), by = "1 day")), 
    lubridate::yday(seq(as.Date("2025-07-28"), as.Date("2025-08-01"), by = "1 day"))
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
    "Weekend")
  ordered_colors <- c(
    "lightcyan2",
    "pink",
    "darkorchid1", 
    "darkolivegreen1", 
    #"darkolivegreen4", 
    "grey80")[order(desired_order)]
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
    height = 10)
  
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
  ggplot2::ggsave(
    filename = file.path(dir, paste0(year, "_calendar_wide.png")),
    width = 10, 
    height = 6)
}

