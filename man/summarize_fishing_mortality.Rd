% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_fishing_mortality.R
\name{summarize_fishing_mortality}
\alias{summarize_fishing_mortality}
\title{Comparison between recent average mortality, OFLs,
and ACLs. The official recent average mortality should
come from the GEMM rather than a pull from PacFIN.
The manage_file is a file containing management quantities
provided in a special pull by Rob Ames from the GMT016 table.
This special pull of all management quantities by species across years
had some issues that had to be fixed by hand:
\enumerate{
\item Many rockfish species were missing "Rockfish" in their names and
I had to correct them by hand due to grep issues when only the first
name were used (e.g., China changed to China Rockfish).
\item The file does not contain OFLs or ACLs for sablefish, longspine
thornyhead, and shortspine thornyhead.
\item Quantities (OFLs,..) were duplicated for blue rockfish and rougheye/blackspotted
rockfish and had to be corrected by hand.
}}
\usage{
summarize_fishing_mortality(
  manage_file,
  species_file,
  years,
  manage_quants = c("Overfishing Limit", "Annual Catch Limit")
)
}
\arguments{
\item{manage_file}{CSV file with OFLs, ABCs, and ACLs across years for West Coast groundfish}

\item{species_file}{CSV file in the data folder called "species_names.csv" that includes
all the species to include in this analysis.}

\item{years}{The specific year to summarize the management quantities (OFLs, ABCs, ACLs).}

\item{manage_quants}{The names of the management quantities in the manage_file to grep.
This allows to easily shift between the ABC and the ACL if needed.}
}
\description{
Comparison between recent average mortality, OFLs,
and ACLs. The official recent average mortality should
come from the GEMM rather than a pull from PacFIN.
The manage_file is a file containing management quantities
provided in a special pull by Rob Ames from the GMT016 table.
This special pull of all management quantities by species across years
had some issues that had to be fixed by hand:
\enumerate{
\item Many rockfish species were missing "Rockfish" in their names and
I had to correct them by hand due to grep issues when only the first
name were used (e.g., China changed to China Rockfish).
\item The file does not contain OFLs or ACLs for sablefish, longspine
thornyhead, and shortspine thornyhead.
\item Quantities (OFLs,..) were duplicated for blue rockfish and rougheye/blackspotted
rockfish and had to be corrected by hand.
}
}
\examples{
library(nwfscSurvey)

summarize_fishing_mortality(
		file_name <- "commercial_mortality.csv"
		manage_file <- "WOC_STOCK_SUMMARY11232021.csv"
		species_file <-  "species_names.csv"
		years <- 2018:2020
)


}
\author{
Chantel Wetzel
}
