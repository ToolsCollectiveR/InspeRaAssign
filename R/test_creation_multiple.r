#' Create multiple tests in Inspera
#'
#' This function creates multiple tests in the Inspera system using the provided parameters.
#' The number of tests to create is determined by the NUM_TESTS variable in the .env file.
#' The external_test_id is generated automatically.
#'
#' @param template_id The ID of the template to use for the tests
#' @param title_prefix A prefix for the test titles
#' @param start_time The start time of the first test (in ISO 8601 format)
#' @param duration The duration of each test in minutes
#' @param gap_between_tests The time gap between tests in minutes
#'
#' @return A list containing the created test data for each test, or NULL if creation failed
#' @export
create_multiple_tests <- function(template_id, title_prefix, start_time, duration, gap_between_tests) {
  # Load the number of tests from .env file
  num_tests <- as.numeric(Sys.getenv("NUM_TESTS"))
  if (is.na(num_tests) || num_tests <= 0) {
    futile.logger::flog.error("Invalid NUM_TESTS value in .env file")
    return(NULL)
  }

  results <- list()

  for (i in 1:num_tests) {
    # Generate a unique external_test_id
    external_test_id <- paste0("test_", format(Sys.time(), "%Y%m%d%H%M%S"), "_", i)
    title <- paste0(title_prefix, " ", i)
    
    # Calculate start and end times for each test
    test_start_time <- lubridate::ymd_hms(start_time) + lubridate::minutes((i - 1) * (duration + gap_between_tests))
    test_end_time <- test_start_time + lubridate::minutes(duration)

    futile.logger::flog.info("Creating test %d of %d", i, num_tests)
    futile.logger::flog.info("External Test ID: %s", external_test_id)
    
    result <- create_new_test(
      template_id = template_id,
      external_test_id = external_test_id,
      title = title,
      start_time = format(test_start_time, "%Y-%m-%dT%H:%M:%SZ"),
      end_time = format(test_end_time, "%Y-%m-%dT%H:%M:%SZ"),
      duration = duration
    )

    if (is.null(result)) {
      futile.logger::flog.error("Failed to create test %d. Stopping process.", i)
      return(results)
    }

    results[[i]] <- result
    futile.logger::flog.info("Successfully created test %d", i)
  }

  return(results)
}