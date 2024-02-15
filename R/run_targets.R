# Run targets for assessment prioritization
library(targets)

targets::tar_make(script = "_targets.R")
#targets::tar_glimpse()
targets::tar_visnetwork(targets_only = TRUE) # , allow = starts_with("recreational"))
