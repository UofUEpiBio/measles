# Usage in R: source("https://mac.R-project.org/bin/install.R")
# .. and follow instructions
#
# Installs static binaries of libraries used by CRAN to build packages.
# See https://github.com/R-macos/recipes
#
# (C)2021-24 R Core Team, License: MIT, Author: Simon Urbanek

install.libs <- function(pkgs, url = "https://mac.R-project.org/bin",
                         os = tolower(paste0(system("uname -s", intern = TRUE),
                           gsub("\\..*", "", system("uname -r", intern = TRUE)))),
                         arch = system("uname -m", intern = TRUE), os.arch = "auto",
                         dependencies = TRUE, action = c("install", "list", "download"),
                         quiet = FALSE) {
  up <- function(...) paste(..., sep = "/")
  action <- match.arg(action)

  old_options <- options(timeout = 120)
  on.exit(options(old_options))

  if (os.arch == "auto") {
    rindex <- up(url, "REPOS")
    if (!quiet) cat("Downloading", rindex, "...\n")
    rl <- readLines(u <- url(rindex))
    close(u)
    rla <- simplify2array(strsplit(rl[grep("/", rl)], "/"))
    rl <- data.frame(os = rla[1, ], arch = rla[2, ])

    os.name <- function(os) gsub("[0-9].*", "", os)
    os.ver <- function(os) as.numeric(sub("\\..*", "", gsub("[^0-9]*", "", os)))

    rl$os.name <- os.name(rl$os)
    rl$os.ver <- os.ver(rl$os)

    rl <- rl[rl$os.name == os.name(os) & rl$os.ver <= os.ver(os), ]
    if (nrow(rl) < 1)
      stop("There is no repository that supports ", os.name(os), " version ", os.ver(os), " or higher.\nAvailable binaries only support: ",
        paste(rla[1, ], collapse = ", "))

    if (!any(rl$arch == arch))
      stop("Architecture ", arch, " is not supported on os ", os, ", only available architectures: ", rl$arch)

    rl <- rl[rl$arch == arch, ]
    rl <- rl[order(rl$os.ver, decreasing = TRUE), ][1, ]

    os.arch <- file.path(rl$os, rl$arch)
  }

  if (!quiet) cat("Using repository ", up(url, os.arch), "...\n")

  deps <- function(pkgs, db) {
    ## convert bare (w/o version) names to full names
    bare <- pkgs %in% db[, "Package"]
    if (any(bare))
      pkgs[bare] <- rownames(db)[match(pkgs[bare], db[, "Package"])]

    ## any missing?
    mis <- !pkgs %in% rownames(db)
    if (any(mis)) stop("Following binaries have no download candidates: ", paste(pkgs[mis], collapse = ", "))

    dep <- function(pkgs) {
      mis <- !pkgs %in% rownames(db)
      if (any(mis)) stop("Following binaries have no download candidates: ", paste(pkgs[mis], collapse = ", "))

      nd <- na.omit(unique(c(pkgs, unlist(strsplit(db[pkgs, "BuiltWith"], "[, ]+")))))
      if (length(unique(pkgs)) < length(nd)) dep(nd) else nd
    }
    if (dependencies) dep(pkgs) else pkgs
  }

  pindex <- up(url, os.arch, "PACKAGES")
  if (!quiet) cat("Downloading index ", pindex, "...\n")
  db <- read.dcf(u <- url(pindex))
  close(u)
  rownames(db) <- if ("Bundle" %in% colnames(db))
    ifelse(is.na(db[, "Bundle"]),
      paste(db[, "Package"], db[, "Version"], sep = "-"),
      db[, "Bundle"]) else
    paste(db[, "Package"], db[, "Version"], sep = "-")

  if (identical(pkgs, "all")) pkgs <- na.omit(db[, "Package"])
  need <- deps(pkgs, db)
  ## remove bundles as they have no binary
  if ("Bundle" %in% colnames(db) && any(rem <- need %in% na.omit(db[, "Bundle"])))
    need <- need[!rem]
  urls <- up(url, os.arch, db[need, "Binary"])

  if (action == "install") for (u in urls) {
    if (!quiet) cat("Downloading + installing ", u, "...\n")
    if (system(paste("curl", "--connect-timeout 20 --max-time 120", "-sSL", shQuote(u), "|", "tar fxj - -C /")) < 0)
      stop("Failed to install from ", u)
  } else if (action == "download") for (u in urls) {
    if (!file.exists(basename(u))) {
      if (!quiet) cat("Downloading ", u, "...\n", sep = "")
      if (system(paste("curl", "--connect-timeout 20 --max-time 120", "-sSLO", shQuote(u))) < 0)
        stop("Failed to download ", u)
    }
  } else urls
}

## allow SILENT_INSTALL_R=1 to silence the usage
if (!nzchar(Sys.getenv("SILENT_INSTALL_R")))
  cat("\n Usage: install.libs(names)\n\n Example: install.libs('cairo')\n\n names can be a vector or a special value 'all'.\n See args(install.libs) for defaults.\n\n")
