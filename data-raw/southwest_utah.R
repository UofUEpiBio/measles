# This file generates the data for the southwest Utah measles vignette
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
southwest_utah <- rbind(
  with(hildale_data, data.frame(city = "Hildale, UT", age_labels, age_pops)),
  with(colorado_city_data, data.frame(city = "Colorado City, AZ", age_labels, age_pops))
) |> data.table()

southwest_utah <- southwest_utah[,
  .(agepops = sum(age_pops)), by = "age_labels"
]

# Preparing the data for Damon's package
southwest_utah[, agelims := as.integer(gsub("to.+", "", age_labels))]
southwest_utah[is.na(agelims), agelims := 70L]

schoolagegroups <- c(2, 2, 3, 3, 4, 4)
schoolpops <- c(100, 100, 200, 200, 200, 200)

southwest_utah_matrix <- contactMatrixAgeSchool(
  southwest_utah$agelims,
  southwest_utah$agepops,
  schoolagegroups,
  schoolpops, schportion = 0.7
)

southwest_utah_matrix |> round(2)

# Ensuring it is row-stochastic
# Future version of epiworld may support non-row-stochastic matrices.
southwest_utah_matrix <- southwest_utah_matrix / rowSums(southwest_utah_matrix)

usethis::use_data(
  southwest_utah_matrix,
  internal = FALSE,
  overwrite = TRUE
)

# We now append the school populations to the southwest_utah data
# substracting the school populations from the age groups
schools <- southwest_utah[schoolagegroups]

schools[, agepops := schoolpops]

schools_pop <- schools[, .(school_p = sum(agepops)), by = .(age_labels)]
southwest_utah <- merge(
  southwest_utah,
  schools_pop,
  all = TRUE,
  by = "age_labels"
)

southwest_utah[!is.na(school_p), agepops := agepops - school_p]
southwest_utah[, school_p := NULL]

# Relabeling data
schools[, age_labels := paste0(age_labels, "s", .I)]

# Putting all together
southwest_utah <- rbind(
  southwest_utah,
  schools
)
southwest_utah[age_labels == "70plus", age_labels := "70+"]
southwest_utah[age_labels == "0to4", age_labels := "under5"]

# Sorting according to the mixing matrix
ids <- match(
  colnames(southwest_utah_matrix), southwest_utah$age_labels
)

ids <- ids[!is.na(ids)]
southwest_utah <- southwest_utah[ids]

# Ensuring ti works
stopifnot(
  all(southwest_utah$age_labels == colnames(southwest_utah_matrix))
)

# Adding a fake vaccination rate
southwest_utah[, vacc_rate := 0.9]
southwest_utah[grepl("s", age_labels), vacc_rate := 0.5]

usethis::use_data(
  southwest_utah,
  internal = FALSE,
  overwrite = TRUE
)
