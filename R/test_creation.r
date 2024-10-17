#' Create a new test in Inspera
#'
#' This function creates a new test in the Inspera system using the provided parameters.
#'
#' @param template_id The ID of the template to use for the test
#' @param external_test_id An external ID for the test
#' @param title The title of the test
#' @param start_time The start time of the test (in ISO 8601 format)
#' @param end_time The end time of the test (in ISO 8601 format)
#' @param duration The duration of the test in minutes
#'
#' @return A list containing the created test data, or NULL if creation failed
#' @export
create_new_test <- function(template_id, external_test_id, title, start_time, end_time, duration) {
  access_token <- get_access_token()
  
  url <- "https://nokut.inspera.no/api/v1/test?isExternal=true"
  
  futile.logger::flog.info("Attempting to create test with URL: %s", url)
  futile.logger::flog.info("Using template ID: %s", template_id)
  
  body <- list(
    externalTestId = external_test_id,
    title = title,
    startTime = start_time,
    endTime = end_time,
    duration = duration,
    sourceTemplateId = template_id
  )
  
  req <- httr2::request(url) %>%
    httr2::req_headers(
      Authorization = paste("Bearer", access_token),
      "Content-Type" = "application/json"
    ) %>%
    httr2::req_body_json(body) %>%
    httr2::req_method("POST")
  
  tryCatch({
    resp <- httr2::req_perform(req)
    test_data <- httr2::resp_body_json(resp)
    
    if (test_data$success == TRUE && !is.null(test_data$assessmentRunId)) {
      futile.logger::flog.info("New test created successfully. Assessment Run ID: %s", test_data$assessmentRunId)
      
      # Collect and store metadata
      metadata <- data.frame(
        assessment_run_id = test_data$assessmentRunId,
        test_name = title,
        creation_date = lubridate::today(),
        stringsAsFactors = FALSE
      )
      
      output_file <- paste0(format(lubridate::today(), "%Y-%m-%d"), "_test_created.csv")
      readr::write_csv(metadata, output_file)
      
      futile.logger::flog.info("Test metadata stored in file: %s", output_file)
      
      return(test_data)
    } else {
      futile.logger::flog.error("Failed to create test. Unexpected response format.")
      futile.logger::flog.error("Response: %s", jsonlite::toJSON(test_data, auto_unbox = TRUE))
      return(NULL)
    }
  }, error = function(e) {
    futile.logger::flog.error("Error creating new test: %s", e$message)
    if (inherits(e, "httr2_http_error")) {
      futile.logger::flog.error("HTTP Status: %d", e$response$status_code)
      futile.logger::flog.error("Response body: %s", httr2::resp_body_string(e$response))
    }
    return(NULL)
  })
}