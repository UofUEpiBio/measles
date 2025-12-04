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

# Vaccine effectiveness by age group (adjusted for these age groups)
# Using approximate values for these broader age categories
ageveff <- rep(0.97, length(agelims))  # Most age groups have high effectiveness
ageveff[1] <- 0.93  # Under 5 may have slightly lower effectiveness

# Initial infection in the 25-29 age group (working age adults)
# This corresponds to age group 25-29 (index 6)
initgrp <- 6

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

  cat("\n", city, ":\n", sep = "")
  cat("  Total population:", format(data$total_pop, big.mark = ","), "\n")
  cat("  Age distribution:\n")
  for (i in seq_along(data$age_labels)) {
    pct <- 100 * data$age_pops[i] / data$total_pop
    cat(sprintf("    %s: %s (%.1f%%)\n",
      data$age_labels[i],
      format(data$age_pops[i], big.mark = ","),
      pct))
  }
}

# We extract only the age and pops
hildale_data <- city_data_list[["Hildale city, Utah"]][c("age_labels", "age_pops")]
colorado_city_data <- city_data_list[["Colorado City town, Arizona"]][c("age_labels", "age_pops")]

# Preparing both in a single data.frame
southwest_utah <- rbind(
  with(hildale_data, data.frame(city = "Hildale, UT", age_labels, age_pops)),
  with(colorado_city_data, data.frame(city = "Colorado City, AZ", age_labels, age_pops))
) |> data.table()

southwest_utah <- southwest_utah[,
  .(agepops = sum(age_pops)), by = "age_labels"
]

# Preparing the data for Damon's package
southwest_utah[, agelims := as.integer(gsub(".+to", "", age_labels))]
southwest_utah[is.na(agelims), agelims := 100L]

schoolagegroups <- c(3, 3, 4, 4, 5, 5)
schoolpops <- c(350, 350, 100, 100, 200, 200)

contactMatrixAgeSchool(
  southwest_utah$agelims,
  southwest_utah$agepops,
  schoolagegroups,
  schoolpops, schportion = 0.7
)
