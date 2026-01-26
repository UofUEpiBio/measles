# Most of this R script was created based on the vignette
# by the multigroup.vaccine package.
# Date: Monday, Jan 26, 2026
# https://github.com/EpiForeSITE/multigroup-vaccine/blob/3047ebf568c9b2028336dc14af587a282de9e225/vignettes/experiments/shortcreek_age_school.Rmd

library(multigroup.vaccine)
library(socialmixr)
library(data.table)

# Load city data files
hildale_path <- system.file("extdata", "hildale_ut_2023.csv", package = "multigroup.vaccine")
colorado_city_path <- system.file("extdata", "colorado_city_az_2023.csv", package = "multigroup.vaccine")
centennial_park_path <- system.file("extdata", "centennial_park_az_2023.csv", package = "multigroup.vaccine")


# ## Measles Model Setup

# For measles outbreak modeling, let's use the following age groups:

agelims <- c(0, 1, 5, 12, 14, 18, 25, 45, 70)
ageveff <- c(0.93, 0.93, rep(0.97, 6), 1)


## Getting City Population Data


hildale <- getCityData(
  city_name = "Hildale city, Utah",
  csv_path = hildale_path,
  age_groups = agelims
)

colorado_city <- getCityData(
  city_name = "Colorado City town, Arizona",
  csv_path = colorado_city_path,
  age_groups = agelims
)

centennial_park <- getCityData(
  city_name = "Centennial Park CDP, Arizona",
  csv_path = centennial_park_path,
  age_groups = agelims
)

agepops <- round(hildale$age_pops + colorado_city$age_pops + centennial_park$age_pops)


## School data


schoolpops <- c(250, 350, 190, 86, 150, 84, 114, 108, 205)
schoolagegroups <- c(3, 3, 3, 4, 4, 4, 5, 5, 5)
schoolvax <- c(16, 129, 80, 20, 55, 50, 27, 40, 93)

knitr::kable(data.frame(school = c(paste0("elem", 1:3),
  paste0("middle", 1:3),
  paste0("high", 1:3)),
enrolled = schoolpops,
MMRcoverage = paste0(round(100 * schoolvax / schoolpops), "%")),
row.names = FALSE, format = "markdown")


## Create contact matrix and immunization vector


# Readjust the school populations to match the age data:
for (a in unique(schoolagegroups)) {
  inds <- which(schoolagegroups == a)
  schoolpops[inds] <- round(agepops[a] * schoolpops[inds] / sum(schoolpops[inds]))
}
cm <- contactMatrixAgeSchool(agelims, agepops, schoolagegroups, schoolpops, schportion = 0.7)
grouppops <- c(agepops[1:(min(schoolagegroups) - 1)],
  schoolpops,
  agepops[(max(schoolagegroups) + 1):length(agepops)])
groupvax <- rep(0, nrow(cm))

groupvax[1] <- 0 # Under 1 unvaccinated
groupvax[2] <- grouppops[2] * sum(schoolvax[schoolagegroups == 3]) / sum(schoolpops[schoolagegroups == 3])
groupvax[3:11] <- schoolvax
groupvax[12] <- grouppops[12] * sum(schoolvax[schoolagegroups == 5]) / sum(schoolpops[schoolagegroups == 5])
groupvax[13] <- grouppops[13] * mean(c(groupvax[12] / grouppops[12], 0.95))
groupvax[14] <- grouppops[14] * 0.95
groupvax[15] <- grouppops[15]

groupveff <- rep(0.97, length(groupvax))
groupveff[1:2] <- 0.93
groupveff[length(groupveff)] <- 1
groupimm <- round(groupvax * groupveff)

knitr::kable(data.frame(group = rownames(cm),
  size = grouppops,
  immunity = paste0(round(100 * groupimm / grouppops), "%")),
row.names = FALSE, format = "markdown")


## Set up outbreak analysis
## STOP()

################################################
# Short Creek Data Preparation
################################################

# Making it row-stochastic for use in epiworld
short_creek_matrix <- cm
short_creek_matrix <- short_creek_matrix / rowSums(short_creek_matrix)

usethis::use_data(
  short_creek_matrix,
  internal = FALSE,
  overwrite = TRUE
)

# Preparing the
short_creek <- data.table(
  age_labels = rownames(short_creek_matrix),
  agepops = grouppops,
  agelims = gsub(
    ".+to([0-9]+).*", "\\1",
    rownames(short_creek_matrix)
  ) |> as.integer(),
  vacc_rate = groupimm / grouppops
)

short_creek[age_labels == "under1", agelims := 1L]
short_creek[age_labels == "70+", agelims := 90L]

usethis::use_data(
  short_creek,
  internal = FALSE,
  overwrite = TRUE
)
