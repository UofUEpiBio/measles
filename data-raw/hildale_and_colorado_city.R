# This file generates the data for the Hildale and Colorado City measles vignette
# The original code was adapted from the multigroup.vaccine package,
# in a vignette by @JakeWags:
# https://github.com/EpiForeSITE/multigroup-vaccine/blob/54acee568fbb0666231ab59f19d33841337d7402/vignettes/hildale_and_colorado_city.Rmd

library(multigroup.vaccine)
library(socialmixr)
library(data.table)

# Load city data files
hildale_path <- system.file(
  "extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine"
)

colorado_city_path <- system.file(
  "extdata", "colorado_city_az_2023.csv", package = "multigroup.vaccine"
)

# Age groups based on ACS 5-year intervals, adjusted to avoid zero populations
agelims <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70)

cities <- c("Hildale city, Utah", "Colorado City town, Arizona")

city_data_list <- list()

for (city in cities) {
  if (grepl("Hildale", city)) {
    csv_path <- hildale_path
  } else {
    csv_path <- colorado_city_path
  }

  data <- getCityData(
    city_name = city,
    csv_path = csv_path,
    age_groups = agelims
  )

  city_data_list[[city]] <- data

}

# We extract only the age and pops
hildale_data <- city_data_list[["Hildale city, Utah"]][
  c("age_labels", "age_pops")
]

colorado_city_data <- city_data_list[["Colorado City town, Arizona"]][
  c("age_labels", "age_pops")
]

# Preparing both in a single data.frame
hildale_and_colorado_city <- rbind(
  with(hildale_data, data.frame(city = "Hildale, UT", age_labels, age_pops)),
  with(colorado_city_data, data.frame(city = "Colorado City, AZ", age_labels, age_pops))
) |> data.table()

hildale_and_colorado_city <- hildale_and_colorado_city[,
  .(agepops = sum(age_pops)), by = "age_labels"
]

# Preparing the data for Damon's package
hildale_and_colorado_city[, agelims := as.integer(gsub("to.+", "", age_labels))]
hildale_and_colorado_city[is.na(agelims), agelims := 70L]

schoolagegroups <- c(2, 2, 3, 3, 4, 4)
schoolpops <- c(100, 100, 200, 200, 200, 200)

hildale_and_colorado_city_matrix <- contactMatrixAgeSchool(
  hildale_and_colorado_city$agelims,
  hildale_and_colorado_city$agepops,
  schoolagegroups,
  schoolpops, schportion = 0.7
)

hildale_and_colorado_city_matrix |> round(2)

# Ensuring it is row-stochastic
# Future version of epiworld may support non-row-stochastic matrices.
hildale_and_colorado_city_matrix <- hildale_and_colorado_city_matrix / rowSums(hildale_and_colorado_city_matrix)

usethis::use_data(
  hildale_and_colorado_city_matrix,
  internal = FALSE,
  overwrite = TRUE
)

# We now append the school populations to the hildale_and_colorado_city data
# substracting the school populations from the age groups
schools <- hildale_and_colorado_city[schoolagegroups]

schools[, agepops := schoolpops]

schools_pop <- schools[, .(school_p = sum(agepops)), by = .(age_labels)]
hildale_and_colorado_city <- merge(
  hildale_and_colorado_city,
  schools_pop,
  all = TRUE,
  by = "age_labels"
)

hildale_and_colorado_city[!is.na(school_p), agepops := agepops - school_p]
hildale_and_colorado_city[, school_p := NULL]

# Relabeling data
schools[, age_labels := paste0(age_labels, "s", .I)]

# Putting all together
hildale_and_colorado_city <- rbind(
  hildale_and_colorado_city,
  schools
)
hildale_and_colorado_city[age_labels == "70plus", age_labels := "70+"]
hildale_and_colorado_city[age_labels == "0to4", age_labels := "under5"]

# Sorting according to the mixing matrix
ids <- match(
  colnames(hildale_and_colorado_city_matrix), hildale_and_colorado_city$age_labels
)

ids <- ids[!is.na(ids)]
hildale_and_colorado_city <- hildale_and_colorado_city[ids]

# Ensuring ti works
stopifnot(
  all(hildale_and_colorado_city$age_labels == colnames(hildale_and_colorado_city_matrix))
)

# Adding a fake vaccination rate
hildale_and_colorado_city[, vacc_rate := 0.9]
hildale_and_colorado_city[grepl("s", age_labels), vacc_rate := 0.5]

usethis::use_data(
  hildale_and_colorado_city,
  internal = FALSE,
  overwrite = TRUE
)
