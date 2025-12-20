# This file generates the data for the Short Creek measles vignette
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

centennial_park_path <- system.file(
  "extdata", "centennial_park_az_2023.csv", package = "multigroup.vaccine"
)

# Age groups based on ACS 5-year intervals, adjusted to avoid zero populations
agelims <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70)

cities <- c(
  "Hildale city, Utah", "Colorado City town, Arizona",
  "Centennial Park CDP, Arizona"
)

city_data_list <- list()

for (city in cities) {
  if (grepl("Hildale", city)) {
    csv_path <- hildale_path
  } else if (grepl("Colorado City", city)) {
    csv_path <- colorado_city_path
  } else if (grepl("Centennial Park", city)) {
    csv_path <- centennial_park_path
  } else {
    stop("Unknown city: ", city)
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

centenial_park_data <- city_data_list[["Centennial Park CDP, Arizona"]][
  c("age_labels", "age_pops")
]

# Preparing both in a single data.frame
short_creek <- rbind(
  with(
    hildale_data,
    data.frame(city = "Hildale, UT", age_labels, age_pops)
  ),
  with(
    colorado_city_data,
    data.frame(city = "Colorado City, AZ", age_labels, age_pops)
  ),
  with(
    centenial_park_data,
    data.frame(city = "Centennial Park, AZ", age_labels, age_pops)
  )
) |> data.table()

short_creek <- short_creek[,
  .(agepops = sum(age_pops)), by = "age_labels"
]

# Preparing the data for Damon's package
short_creek[, agelims := as.integer(gsub("to.+", "", age_labels))]
short_creek[is.na(agelims), agelims := 70L]

schoolpops <- c(250, 350, 190, 86, 150, 84, 114, 108, 205)
schoolagegroups <- c(3, 3, 3, 4, 4, 4, 5, 5, 5)
schoolvax <- c(16, 129, 80, 20, 55, 50, 27, 40, 93)

short_creek_matrix <- contactMatrixAgeSchool(
  short_creek$agelims,
  short_creek$agepops,
  schoolagegroups,
  schoolpops, schportion = 0.7
)

short_creek_matrix |> round(2)

# Ensuring it is row-stochastic
# Future version of epiworld may support non-row-stochastic matrices.
short_creek_matrix <- short_creek_matrix / rowSums(short_creek_matrix)

usethis::use_data(
  short_creek_matrix,
  internal = FALSE,
  overwrite = TRUE
)

# We now append the school populations to the short_creek data
# substracting the school populations from the age groups
schools <- short_creek[schoolagegroups]

schools[, agepops := schoolpops]

schools_pop <- schools[, .(school_p = sum(agepops)), by = .(age_labels)]
short_creek <- merge(
  short_creek,
  schools_pop,
  all = TRUE,
  by = "age_labels"
)

short_creek[!is.na(school_p), agepops := agepops - school_p]
short_creek[, school_p := NULL]

# Relabeling data
schools[, age_labels := paste0(age_labels, "s", .I)]

# Putting all together
short_creek <- rbind(
  short_creek,
  schools
)
short_creek[age_labels == "70plus", age_labels := "70+"]
short_creek[age_labels == "0to4", age_labels := "under5"]

# Sorting according to the mixing matrix
ids <- match(
  colnames(short_creek_matrix), short_creek$age_labels
)

ids <- ids[!is.na(ids)]
short_creek <- short_creek[ids]

# Ensuring ti works
stopifnot(
  all(short_creek$age_labels == colnames(short_creek_matrix))
)

# Adding a fake vaccination rate
short_creek[, vacc_rate := 0.93]
short_creek[
  grepl("s", age_labels),
  vacc_rate := schoolvax / schoolpops
]

usethis::use_data(
  short_creek,
  internal = FALSE,
  overwrite = TRUE
)
