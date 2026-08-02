bind_catalog_datasets <- function(
    datasets,
    catalog,
    component,
    exam = NULL,
    analysis_role = NULL) {
  selected <- select_catalog_rows(
    catalog,
    component = component,
    exam = exam,
    analysis_role = analysis_role
  )
  if (nrow(selected) == 0L) {
    stop("No catalog rows matched component ", component, call. = FALSE)
  }
  dplyr::bind_rows(datasets[selected$dataset_id])
}

write_validated_dataset <- function(data, stem, output_dir, write_csv = FALSE) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  rds_path <- file.path(output_dir, paste0(stem, ".rds"))
  saveRDS(data, rds_path, compress = "xz")
  if (write_csv) {
    utils::write.csv(
      data,
      file.path(output_dir, paste0(stem, ".csv")),
      row.names = FALSE,
      na = ""
    )
  }
  rds_path
}

run_nhanes_pipeline <- function(
    catalog_path = "config/nhanes_files.csv",
    cache_dir = "data/raw",
    output_dir = "data/derived",
    refresh = TRUE,
    write_csv = FALSE) {
  catalog <- read_nhanes_catalog(catalog_path)
  paths <- download_catalog_files(catalog, cache_dir = cache_dir, refresh = refresh)
  datasets <- read_catalog_files(catalog, paths)

  cbc_primary <- bind_catalog_datasets(
    datasets, catalog, component = "cbc", exam = "primary", analysis_role = "primary"
  )
  cbc_second_exam <- bind_catalog_datasets(
    datasets, catalog, component = "cbc", exam = "second", analysis_role = "supplementary"
  )
  demographics <- bind_catalog_datasets(
    datasets, catalog, component = "demographics", analysis_role = "primary"
  )

  assert_unique_key(cbc_primary, c("SEQN", "cycle"), "Primary CBC")
  assert_unique_key(cbc_second_exam, c("SEQN", "cycle", "exam"), "Second-exam CBC")
  assert_unique_key(demographics, c("SEQN", "cycle"), "Demographics")
  assert_all_keys_present(
    cbc_primary,
    demographics,
    c("SEQN", "cycle"),
    "primary CBC",
    "demographics"
  )

  cbc_demographics <- dplyr::left_join(
    cbc_primary,
    demographics,
    by = c("SEQN", "cycle"),
    suffix = c("_cbc", "_demo")
  )
  assert_unique_key(cbc_demographics, c("SEQN", "cycle"), "CBC-demographics merge")
  if (nrow(cbc_demographics) != nrow(cbc_primary)) {
    stop("CBC-demographics join changed the primary CBC row count.", call. = FALSE)
  }

  output_paths <- c(
    cbc_primary = write_validated_dataset(
      cbc_primary, "cbc_primary_1999_2018", output_dir, write_csv
    ),
    cbc_second_exam = write_validated_dataset(
      cbc_second_exam, "cbc_second_exam_2001_2002", output_dir, write_csv
    ),
    demographics = write_validated_dataset(
      demographics, "demographics_1999_2018", output_dir, write_csv
    ),
    cbc_demographics = write_validated_dataset(
      cbc_demographics, "cbc_demographics_1999_2018", output_dir, write_csv
    )
  )

  provenance <- build_provenance(catalog, paths, datasets)
  validation <- do.call(rbind, list(
    validation_row("cbc_primary_1999_2018", cbc_primary),
    validation_row("cbc_second_exam_2001_2002", cbc_second_exam),
    validation_row("demographics_1999_2018", demographics),
    validation_row("cbc_demographics_1999_2018", cbc_demographics)
  ))
  utils::write.csv(provenance, file.path(output_dir, "provenance.csv"), row.names = FALSE)
  utils::write.csv(validation, file.path(output_dir, "validation.csv"), row.names = FALSE)

  message("Validated outputs written to ", normalizePath(output_dir, mustWork = TRUE))
  invisible(list(
    catalog = catalog,
    provenance = provenance,
    validation = validation,
    paths = output_paths,
    data = list(
      cbc_primary = cbc_primary,
      cbc_second_exam = cbc_second_exam,
      demographics = demographics,
      cbc_demographics = cbc_demographics
    )
  ))
}
