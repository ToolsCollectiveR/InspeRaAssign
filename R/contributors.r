### contributors.R

#' Assign contributors to a test
#'
#' @param test_id Test ID
#' @param contributors List of contributors
#' @return List containing test ID and response status
#' @export
#' @importFrom httr2 request req_headers req_body_json req_method req_perform resp_status
#' @importFrom dotenv load_dot_env
#' @importFrom magrittr %>%
assign_contributors <- function(test_id, contributors) {
  # Load environment variables from .env file
  dotenv::load_dot_env()

  # Read access token from environment variable
  access_token <- Sys.getenv("INSPERA_ACCESS_TOKEN")

  if (access_token == "") {
    stop("Access token not found in environment variables.")
  }

  body <- list(
    contributors = contributors,
    authenticationSystem = "YourAuthSystem"
  )

  url <- paste0("https://nokut.inspera.no/api/v1/test/", test_id, "/contributors")
  req <- httr2::request(url)
  req <- httr2::req_headers(req, Authorization = paste("Bearer", access_token))
  req <- httr2::req_body_json(req, body)
  req <- httr2::req_method(req, "POST")
  resp <- httr2::req_perform(req)

  list(test_id = test_id, status = httr2::resp_status(resp))
}

#' Assign contributors to multiple tests
#'
#' @param test_ids Vector of test IDs
#' @param contributors List of contributors
#' @return Data frame with assignment results
#' @export
#' @importFrom purrr map_dfr
assign_contributors_bulk <- function(test_ids, contributors) {
  purrr::map_dfr(test_ids, function(id) {
    result <- assign_contributors(id, contributors)
    data.frame(test_id = result$test_id, status = result$status)
  })
}