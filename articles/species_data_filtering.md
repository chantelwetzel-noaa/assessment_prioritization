# Filtering data for non-coastwide FMP species

## Introduction

At the September 2024 Pacific Fishery Management Council (the Council)
meeting, the Council removed species that were predominantly in state
waters from the Fishery Manageemnt Plan (FMP). However, there were
select species, with non-coastwide stock definitions, that were removed
or retained in the FMP depending upon the stock area. The following
species are included in the admended FMP for select stock areas:

- black rockfish in Washington (in the FMP) and Oregon (under
  consideration)
- blue and deacon rockfish Washington (in the FMP) and Oregon (under
  consideration)
- cabezon in Washington
- China rockfish in Washington (in the FMP) and Oregon (under
  consideration)
- copper rockfish in Washington/Oregon (under consideration)
- kelp greening in Washington/Oregon (under consideration)
- quillback rockfish in Washington (in the FMP) and Oregon (under
  consideration)

To date, the stock assessment prioritization has calculated the factors
using coastwide data. In order to move to calculating factors for select
areas off the U.S. West Coast, the data used will need to be filtered.

## Data filtering

Below each data source considered within stock assessment prioritization
is evaluated to determine if filtering data down to the stock areas
included in the FMP is viable.

SSC recommendations:

- The SSC recommendations, the year of the most recent assessment, and
  assessment type does not consider area, although historically species
  have been assessed in all stock areas in the same year (i.e., except
  for yellowtail rockfish in 2025).
- Conclusion: **Does not require filtering**

Mortality:

- Morality for species is determined using the Groundfish Expanded
  Multiyear Mortality report to determine average mortality which is
  compared against the current and future harvest specifications. These
  data can only be split north and south of 40$`^\circ`$ 10$`^\prime`$
  North latitude. The FOS team will only update their mortality
  estimates once the changes are finalized in the federal register.
- Conclusion: **The GEMM provides state specific estimates for black
  rockfish, cabezon, kelp greenling, and quillback rockfish (Oregon and
  Washington combined). Blue/deacon rockfish is only split out for
  Oregon. China and copper rockfishes are only available north of
  40$`^\circ`$ 10$`^\prime`$.**
- Action: Create function to filter the select species (black, cabezon,
  kelp greenling, and quillback) that have state specific estimates in
  the GEMM.

Adopted harvest specifications:

- Adopted harvest specifications are provided either on a coastwide
  basis of north and south of 40$`^\circ`$ 10$`^\prime`$ North latitude
  for species managed in a complex, except for a few exceptions.
- Conclusion: **There are state specific harvest specifications for
  quillback rockfish, cabezon, kelp greenling, blue rockfish, black
  rockfish, and copper rockfish. China rockfish is only available north
  of 40$`^\circ`$ 10$`^\prime`$.**
- Action: Create function to filter the select species (quillback,
  cabezon, kelp greenling, blue, black, and copper) harvest
  specifications.

Future harvest specification:

- Future harvest specifications are provided either on a coastwide basis
  of north and south of 40$`^\circ`$ 10$`^\prime`$ North latitude for
  species managed in a complex, except for a few exceptions.
- Conclusion: **Same as adopted harvest specifications.**

Revenue:

- Data from PacFIN which includes a state field.
- Conclusion: **Can be filtered.**
- Action: Create a function to filter revenue for these select species
  to only include Oregon and Washington.

Tribal scores:

- The tribal scores are based upon species important to the tribes in
  Washington state.
- Conclusion: **Data do not need to be filtered.**

Recreational scores:

- Each state has provide species importance with their recreational
  fisheries.
- Conclusion: **Can be filtered**
- Action: Set the species importance to zero in California for the
  select species above.

Abundance measures:

- The abundance by stock is calculated using information from the most
  recent assessments or from available PSA scores.
- Conclusion: **Can be filtered, except for china rockfish which has two
  assessments for the area north of 40$`^\circ`$ 10$`^\prime`$.**
- Action: Delete model files for California species and add the most
  recent kelp greenling and china rockfish assessments.

Survey data:

- Survey data which includes latitude of sample location.
- Conclusion: **Can be filtered**
- Action: Create script to filter by state for these species.

Model files:

- The abundance by stock is calculated using information from the most
  recent assessments or from available PSA scores.
- Conclusion: **Can be filtered, except for china rockfish which has two
  assessments for the area north of 40$`^\circ`$ 10$`^\prime`$.**
- Action: Delete model files for California species and add the most
  recent kelp greenling and china rockfish assessments.
