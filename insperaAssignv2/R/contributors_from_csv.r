### contributors_from_csv.R

#' Get a new access token
#'
#' @return A string containing the new access token
#' @importFrom httr2 request req_headers req_body_form req_method req_perform resp_status resp_body_json
#' @export
get_access_token <- function() {
  # ... (unchanged)
}

#' Assign contributors to a test
#'
#' @param test_id Test ID
#' @param contributors List of contributors
#' @param committees List of committee names
#' @return List containing test ID and response status
#' @importFrom httr2 request req_headers req_body_json req_method req_perform resp_status
assign_contributors <- function(test_id, contributors, committees) {
  access_token <- Sys.getenv("INSPERA_ACCESS_TOKEN")

  if (access_token == "") {
    stop("Access token not found in environment variables.")
  }

  body <- list(
    contributors = contributors,
    authenticationSystem = "YourAuthSystem",
    committeesName = committees
  )

  url <- paste0("https://nokut.inspera.no/api/v1/test/", test_id, "/contributors")
  req <- request(url)
  req <- req_headers(req, Authorization = paste("Bearer", access_token))
  req <- req_body_json(req, body)
  req <- req_method(req, "POST")
  resp <- req_perform(req)

  list(test_id = test_id, status = resp_status(resp))
}

#' Load test IDs, contributors, and committees from separate CSV files and assign contributors to tests
#'
#' @param test_id_csv Path to the CSV file containing test IDs
#' @param contributors_csv Path to the CSV file containing contributors and committees
#' @return Data frame with assignment results
#' @importFrom readr read_csv
#' @importFrom purrr map_dfr
#' @export
assign_contributors_from_csv <- function(test_id_csv = NULL, contributors_csv = NULL) {
  # If file paths are not provided, use environment variables
  if (is.null(test_id_csv)) {
    test_id_csv <- Sys.getenv("TEST_ID_CSV_PATH")
  }
  if (is.null(contributors_csv)) {
    contributors_csv <- Sys.getenv("CONTRIBUTORS_CSV_PATH")
  }

  # Check if files exist
  if (!file.exists(test_id_csv)) {
    stop("Test ID CSV file not found: ", test_id_csv)
  }
  if (!file.exists(contributors_csv)) {
    stop("Contributors CSV file not found: ", contributors_csv)
  }

  # Read CSV files
  test_data <- read_csv(test_id_csv, show_col_types = FALSE)
  contributor_data <- read_csv(contributors_csv, show_col_types = FALSE)

  # Check if required columns exist
  if (!"AssessmentRunId" %in% names(test_data)) {
    stop("Test ID CSV file must contain column: AssessmentRunId")
  }
  if (!"contributor" %in% names(contributor_data)) {
    stop("Contributors CSV file must contain column: contributor")
  }
  if (!"committee" %in% names(contributor_data)) {
    stop("Contributors CSV file must contain column: committee")
  }

  # Get unique list of contributors and committees
  contributors <- unique(contributor_data$contributor)
  committees <- unique(contributor_data$committee)

  # Refresh the access token before assigning contributors
  new_token <- get_access_token()
  Sys.setenv(INSPERA_ACCESS_TOKEN = new_token)

  # Assign contributors for each test
  results <- map_dfr(test_data$AssessmentRunId, function(test_id) {
    result <- assign_contributors(test_id, contributors, committees)
    data.frame(test_id = result$test_id, status = result$status)
  })

  return(results)
}