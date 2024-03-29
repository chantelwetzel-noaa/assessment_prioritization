% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_const_demand.R
\name{summarize_const_demand}
\alias{summarize_const_demand}
\title{Calculations used for the "Const Demand" tab for assessment prioritization.
The values used in the constituent demand tab are primarily scored qualitatively.
This function will provied the state, gear, and sector (commercial vs. recreational)
differences across the states and coastwide which then can be qualitatively
used to input modifiers.}
\usage{
summarize_const_demand(
  commercial_name,
  rec_file,
  species_file,
  years,
  max_exp = 0.18
)
}
\arguments{
\item{rec_file}{A csv file with recreational importance factor calculation}

\item{species_file}{A csv file with species names to summarize}

\item{years}{Years to average the commercial revenue across.}

\item{max_exp}{Numeric value that will be applied to create a spread across ranked
species calculated as: value ^ max_exp}

\item{commercial_file}{A csv file with commercial revenue and gear codes downloaded
from PacFIN (via login account).}
}
\description{
Calculations used for the "Const Demand" tab for assessment prioritization.
The values used in the constituent demand tab are primarily scored qualitatively.
This function will provied the state, gear, and sector (commercial vs. recreational)
differences across the states and coastwide which then can be qualitatively
used to input modifiers.
}
\examples{

summarize_const_demand(
		commercial_file <- "commercial_revenue_with_gear_code.csv"
		rec_file <- "recreational_importance.csv"
		species_file <-  "species_names.csv"
		years <- 2016:2020
)

}
\author{
Chantel Wetzel
}
