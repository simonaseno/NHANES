script_argument <- grep("^--file=", commandArgs(), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", script_argument))
project_root <- dirname(dirname(script_path))
setwd(project_root)
source(file.path("scripts", "load_project.R"))

test <- function(description, code) {
  tryCatch(
    {
      force(code)
      message("PASS: ", description)
    },
    error = function(error) {
      message("FAIL: ", description, "\n  ", conditionMessage(error))
      stop(error)
    }
  )
}

expect_error <- function(code, pattern = NULL) {
  error <- tryCatch({
    force(code)
    NULL
  }, error = identity)
  if (is.null(error)) {
    stop("Expected an error but none was raised.", call. = FALSE)
  }
  if (!is.null(pattern) && !grepl(pattern, conditionMessage(error), fixed = TRUE)) {
    stop("Error did not contain expected text: ", pattern, call. = FALSE)
  }
  invisible(error)
}

test("production catalog is complete and valid", {
  catalog <- read_nhanes_catalog("config/nhanes_files.csv")
  stopifnot(nrow(catalog) == 21L)
  stopifnot(sum(catalog$component == "cbc" & catalog$exam == "primary") == 10L)
  stopifnot(sum(catalog$component == "cbc" & catalog$exam == "second") == 1L)
  stopifnot(sum(catalog$component == "demographics") == 10L)
})

test("catalog rejects duplicate identifiers", {
  catalog <- read_nhanes_catalog("config/nhanes_files.csv")
  catalog$dataset_id[[2]] <- catalog$dataset_id[[1]]
  expect_error(validate_nhanes_catalog(catalog), "dataset_id values must be unique")
})

test("scientific pipeline separates the second exam and preserves primary keys", {
  root <- tempfile("nhanes-test-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  cache <- file.path(root, "raw")
  output <- file.path(root, "derived")
  dir.create(cache)

  catalog <- data.frame(
    dataset_id = c("cbc_primary", "cbc_second", "demo"),
    cycle = c("2001-2002", "2001-2002", "2001-2002"),
    cycle_start = c(2001L, 2001L, 2001L),
    cycle_end = c(2002L, 2002L, 2002L),
    component = c("cbc", "cbc", "demographics"),
    file_id = c("CBC_PRIMARY", "CBC_SECOND", "DEMO_TEST"),
    exam = c("primary", "second", "not_applicable"),
    analysis_role = c("primary", "supplementary", "primary"),
    record_level = "person",
    merge_key = "SEQN",
    expected_rows = c(3L, 2L, 4L),
    url = c(
      "https://wwwn.cdc.gov/test/CBC_PRIMARY.xpt",
      "https://wwwn.cdc.gov/test/CBC_SECOND.xpt",
      "https://wwwn.cdc.gov/test/DEMO_TEST.xpt"
    ),
    stringsAsFactors = FALSE
  )
  catalog_path <- file.path(root, "catalog.csv")
  utils::write.csv(catalog, catalog_path, row.names = FALSE)

  haven::write_xpt(
    data.frame(SEQN = c(1, 2, 3), LBXHGB = c(13.1, 14.2, 12.8)),
    file.path(cache, "cbc_primary.xpt")
  )
  haven::write_xpt(
    data.frame(SEQN = c(1, 2), LB2HGB = c(13.3, 14.0), LB2DAY = c(10, 12)),
    file.path(cache, "cbc_second.xpt")
  )
  haven::write_xpt(
    data.frame(SEQN = c(1, 2, 3, 4), RIDAGEYR = c(20, 30, 40, 50)),
    file.path(cache, "demo.xpt")
  )

  result <- run_nhanes_pipeline(
    catalog_path = catalog_path,
    cache_dir = cache,
    output_dir = output,
    refresh = FALSE,
    write_csv = TRUE
  )

  stopifnot(nrow(result$data$cbc_primary) == 3L)
  stopifnot(nrow(result$data$cbc_second_exam) == 2L)
  stopifnot(nrow(result$data$cbc_demographics) == 3L)
  stopifnot(!anyDuplicated(result$data$cbc_demographics[c("SEQN", "cycle")]))
  stopifnot(all(c("provenance.csv", "validation.csv") %in% list.files(output)))
})

test("duplicate primary participant keys fail validation", {
  duplicate_data <- data.frame(SEQN = c(1, 1), cycle = c("2001-2002", "2001-2002"))
  expect_error(
    assert_unique_key(duplicate_data, c("SEQN", "cycle"), "Synthetic CBC"),
    "duplicate rows"
  )
})

message("All tests passed.")
