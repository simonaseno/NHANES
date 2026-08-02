required_catalog_columns <- function() {
  c(
    "dataset_id", "cycle", "cycle_start", "cycle_end", "component",
    "file_id", "exam", "analysis_role", "record_level", "merge_key",
    "expected_rows", "url"
  )
}

read_nhanes_catalog <- function(path = "config/nhanes_files.csv") {
  if (!file.exists(path)) {
    stop("Catalog does not exist: ", path, call. = FALSE)
  }

  catalog <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  validate_nhanes_catalog(catalog)
  catalog
}

validate_nhanes_catalog <- function(catalog) {
  missing_columns <- setdiff(required_catalog_columns(), names(catalog))
  if (length(missing_columns) > 0L) {
    stop(
      "Catalog is missing columns: ", paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  if (nrow(catalog) == 0L) {
    stop("Catalog cannot be empty.", call. = FALSE)
  }

  character_columns <- setdiff(required_catalog_columns(), c(
    "cycle_start", "cycle_end", "expected_rows"
  ))
  empty_values <- vapply(
    catalog[character_columns],
    function(x) any(is.na(x) | !nzchar(trimws(x))),
    logical(1)
  )
  if (any(empty_values)) {
    stop(
      "Catalog has empty values in: ",
      paste(names(empty_values)[empty_values], collapse = ", "),
      call. = FALSE
    )
  }

  if (anyDuplicated(catalog$dataset_id)) {
    stop("Catalog dataset_id values must be unique.", call. = FALSE)
  }

  if (any(catalog$cycle_start > catalog$cycle_end)) {
    stop("cycle_start cannot be later than cycle_end.", call. = FALSE)
  }

  if (any(is.na(catalog$expected_rows) | catalog$expected_rows < 1L)) {
    stop("expected_rows must contain positive integers.", call. = FALSE)
  }

  supported_roles <- c("primary", "supplementary")
  if (any(!catalog$analysis_role %in% supported_roles)) {
    stop("Unsupported analysis_role in catalog.", call. = FALSE)
  }

  supported_levels <- c("person")
  if (any(!catalog$record_level %in% supported_levels)) {
    stop(
      "This pipeline currently validates only person-level files. ",
      "Add record-level validation before adding other file types.",
      call. = FALSE
    )
  }

  if (any(!grepl("^https://wwwn\\.cdc\\.gov/", catalog$url))) {
    stop("Every catalog URL must use the official HTTPS CDC host.", call. = FALSE)
  }

  invisible(TRUE)
}

select_catalog_rows <- function(
    catalog,
    component = NULL,
    exam = NULL,
    analysis_role = NULL) {
  keep <- rep(TRUE, nrow(catalog))
  if (!is.null(component)) {
    keep <- keep & catalog$component %in% component
  }
  if (!is.null(exam)) {
    keep <- keep & catalog$exam %in% exam
  }
  if (!is.null(analysis_role)) {
    keep <- keep & catalog$analysis_role %in% analysis_role
  }
  catalog[keep, , drop = FALSE]
}
