sha256_file <- function(path) {
  digest::digest(path, algo = "sha256", file = TRUE)
}

download_nhanes_file <- function(
    url,
    destination,
    refresh = TRUE,
    retries = 4L,
    timeout_seconds = 120L) {
  if (!refresh && file.exists(destination) && file.info(destination)$size > 0L) {
    return(normalizePath(destination, mustWork = TRUE))
  }

  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile(
    pattern = paste0(basename(destination), "."),
    tmpdir = dirname(destination)
  )
  on.exit(unlink(temporary), add = TRUE)

  response <- httr::RETRY(
    verb = "GET",
    url = url,
    httr::write_disk(temporary, overwrite = TRUE),
    httr::timeout(timeout_seconds),
    times = retries,
    pause_base = 1,
    pause_cap = 8,
    terminate_on = c(400, 401, 403, 404),
    quiet = TRUE
  )
  httr::stop_for_status(response, task = paste("download", url))

  if (!file.exists(temporary) || file.info(temporary)$size < 100L) {
    stop("Downloaded file is empty or unexpectedly small: ", url, call. = FALSE)
  }

  copied <- file.copy(temporary, destination, overwrite = TRUE)
  if (!copied) {
    stop("Could not move downloaded file to: ", destination, call. = FALSE)
  }

  normalizePath(destination, mustWork = TRUE)
}

download_catalog_files <- function(
    catalog,
    cache_dir = "data/raw",
    refresh = TRUE,
    retries = 4L,
    timeout_seconds = 120L) {
  validate_nhanes_catalog(catalog)
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  paths <- stats::setNames(character(nrow(catalog)), catalog$dataset_id)
  for (index in seq_len(nrow(catalog))) {
    row <- catalog[index, , drop = FALSE]
    destination <- file.path(cache_dir, paste0(row$dataset_id, ".xpt"))
    message("Acquiring ", row$dataset_id, " from ", row$url)
    paths[[row$dataset_id]] <- download_nhanes_file(
      url = row$url,
      destination = destination,
      refresh = refresh,
      retries = retries,
      timeout_seconds = timeout_seconds
    )
  }
  paths
}

read_catalog_files <- function(catalog, paths) {
  validate_nhanes_catalog(catalog)
  missing_paths <- setdiff(catalog$dataset_id, names(paths))
  if (length(missing_paths) > 0L) {
    stop(
      "No downloaded path for: ", paste(missing_paths, collapse = ", "),
      call. = FALSE
    )
  }

  datasets <- stats::setNames(vector("list", nrow(catalog)), catalog$dataset_id)
  for (index in seq_len(nrow(catalog))) {
    row <- catalog[index, , drop = FALSE]
    path <- paths[[row$dataset_id]]
    data <- haven::read_xpt(path)

    if (nrow(data) != row$expected_rows) {
      stop(
        row$dataset_id, " has ", nrow(data), " rows; expected ",
        row$expected_rows, ". Review the upstream revision before proceeding.",
        call. = FALSE
      )
    }
    if (!row$merge_key %in% names(data)) {
      stop(
        row$dataset_id, " is missing declared merge key ", row$merge_key,
        call. = FALSE
      )
    }

    data$cycle <- row$cycle
    data$cycle_start <- row$cycle_start
    data$cycle_end <- row$cycle_end
    data$component <- row$component
    data$exam <- row$exam
    data$analysis_role <- row$analysis_role
    data$record_level <- row$record_level
    data$source_file <- paste0(row$file_id, ".xpt")
    data$source_url <- row$url
    datasets[[row$dataset_id]] <- data
  }
  datasets
}

build_provenance <- function(catalog, paths, datasets) {
  retrieved_at <- format(Sys.time(), tz = "UTC", usetz = TRUE)
  rows <- lapply(seq_len(nrow(catalog)), function(index) {
    row <- catalog[index, , drop = FALSE]
    path <- paths[[row$dataset_id]]
    data <- datasets[[row$dataset_id]]
    data.frame(
      dataset_id = row$dataset_id,
      cycle = row$cycle,
      component = row$component,
      exam = row$exam,
      source_file = paste0(row$file_id, ".xpt"),
      source_url = row$url,
      retrieved_at_utc = retrieved_at,
      bytes = unname(file.info(path)$size),
      sha256 = sha256_file(path),
      rows = nrow(data),
      columns = ncol(data),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}
