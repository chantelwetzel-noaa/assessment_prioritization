# Calculate ranking by stock status

Function that will read output from all models in the model_loc
("model_files") folder. The unfished spawning biomass, final spawning
biomass, sigma R, assessment year, and mean age. The function then takes
these results and calculates a weighted depletion and mean age for
stocks with area based assessments. These results are then added to the
previous cycle's stock status and assessment frequency sheets in the
"data" folder. The updated stock status and assessment frequency csv
files are then saved to the tables folder.

## Usage

``` r
summarize_stock_status(
  abundance,
  species,
  catage_years,
  model_loc = "model_files"
)
```

## Arguments

- abundance:

  R data object that contains the estimated abundance by species. This
  function takes the existing values and adds the estimated abundance
  from new assessments. The csv file to be read is found in the
  data-processed folder called abundance_processed.csv

- species:

  R data object that contains a list of species names to calculate
  assessment prioritization. The csv file with the list of species names
  should be stored in the data-raw folder ("species_names.csv")

- catage_years:

  Vector of specific years to calculate the mean age of the catches by
  species.

- model_loc:

  Directory location to locate model files. The default is "model_files"
  in the assessment prioritization github.

## Author

Chantel Wetzel

## Examples

``` r
if (FALSE) { # \dontrun{
  summarize_stock_status(
      abundance = abundance,
      species = species,
      model_loc = "model_files",
      years = 2000:2020 # Catch-at-Age range
  )
} # }
```
