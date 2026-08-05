script_argument <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_argument) != 1L) {
  stop("Run this script with Rscript.", call. = FALSE)
}
script_path <- normalizePath(sub("^--file=", "", script_argument))
project_root <- dirname(dirname(script_path))
setwd(project_root)
source(file.path("scripts", "load_project.R"))

parse_arguments <- function(arguments) {
  defaults <- list(
    catalog = "config/nhanes_files.csv",
    `cache-dir` = "data/raw",
    `output-dir` = "data/derived",
    refresh = "true",
    `write-csv` = "false"
  )
  for (argument in arguments) {
    if (!grepl("^--[^=]+=.+$", argument)) {
      stop("Arguments must use --name=value: ", argument, call. = FALSE)
    }
    parts <- strsplit(sub("^--", "", argument), "=", fixed = TRUE)[[1]]
    name <- parts[[1]]
    value <- paste(parts[-1], collapse = "=")
    if (!name %in% names(defaults)) {
      stop("Unknown argument: --", name, call. = FALSE)
    }
    defaults[[name]] <- value
  }
  defaults
}

as_flag <- function(value, name) {
  normalized <- tolower(value)
  if (!normalized %in% c("true", "false")) {
    stop("--", name, " must be true or false.", call. = FALSE)
  }
  identical(normalized, "true")
}

options <- parse_arguments(commandArgs(trailingOnly = TRUE))
run_nhanes_pipeline(
  catalog_path = options$catalog,
  cache_dir = options$`cache-dir`,
  output_dir = options$`output-dir`,
  refresh = as_flag(options$refresh, "refresh"),
  write_csv = as_flag(options$`write-csv`, "write-csv")
)
