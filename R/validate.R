assert_unique_key <- function(data, key, label) {
  missing <- setdiff(key, names(data))
  if (length(missing) > 0L) {
    stop(label, " is missing key columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  key_data <- data[key]
  if (any(!stats::complete.cases(key_data))) {
    stop(label, " has missing values in its key.", call. = FALSE)
  }
  if (anyDuplicated(key_data)) {
    stop(label, " has duplicate rows for key: ", paste(key, collapse = " + "), call. = FALSE)
  }
  invisible(TRUE)
}

assert_all_keys_present <- function(left, right, key, left_label, right_label) {
  collapse_key <- function(data) {
    do.call(paste, c(data[key], sep = "\r"))
  }
  left_key <- collapse_key(left)
  right_key <- collapse_key(right)
  missing_count <- sum(!left_key %in% right_key)
  if (missing_count > 0L) {
    stop(
      missing_count, " ", left_label, " keys are absent from ", right_label, ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

validation_row <- function(name, data) {
  data.frame(
    dataset = name,
    rows = nrow(data),
    columns = ncol(data),
    unique_participants = if ("SEQN" %in% names(data)) length(unique(data$SEQN)) else NA_integer_,
    duplicate_participant_rows = if ("SEQN" %in% names(data)) sum(duplicated(data$SEQN)) else NA_integer_,
    stringsAsFactors = FALSE
  )
}
