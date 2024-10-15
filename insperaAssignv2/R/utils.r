### utils.r

#' Save results to CSV
#'
#' @param results Results to save
#' @param file_path File path to save to
#' @export
#' @importFrom readr write_csv
save_results_csv <- function(results, file_path) {
  if (!is.data.frame(results)) {
    results <- as.data.frame(results)
  }
  readr::write_csv(results, file_path)
}

#' Get environment variable with a default value
#'
#' @param var_name Name of the environment variable
#' @param default_value Default value if the environment variable is not set
#' @return The value of the environment variable or the default value
#' @export
get_env_var <- function(var_name, default_value = NULL) {
  value <- Sys.getenv(var_name, unset = NA)
  if (is.na(value)) {
    return(default_value)
  }
  return(value)
}

#' Validate if a required environment variable is set
#'
#' @param var_name Name of the environment variable
#' @export
#' @importFrom futile.logger flog.error
validate_env_var <- function(var_name) {
  value <- Sys.getenv(var_name, unset = NA)
  if (is.na(value)) {
    futile.logger::flog.error("Environment variable '%s' is not set", var_name)
    stop(sprintf("Environment variable '%s' is not set", var_name))
  }
}

#' Get Inspera API access token using environment variable
#'
#' @return Access token as a string
#' @export
#' @importFrom dotenv load_dot_env
#' @importFrom httr2 request req_body_raw req_perform resp_body_json
#' @importFrom purrr pluck
#' @importFrom magrittr %>%
get_access_token <- function() {
  # Load environment variables from .env file
  dotenv::load_dot_env()

  # Read API key from environment variable
  inspera_api_key <- Sys.getenv("INSPERA_API_KEY")

  if (inspera_api_key == "") {
    stop("API key not found in environment variables.")
  }

  # Construct the authentication request URL
  auth_req <- paste0(
    "https://nokut.inspera.no/api/authenticate/token/?code=",
    inspera_api_key,
    "&grant_type=authorization_code&client_id=nokut"
  )

  # Create the request and set body content type
  req <- httr2::request(auth_req)
  req <- httr2::req_body_raw(req, " ", "application/x-www-form-urlencoded")

  # Perform the request
  resp <- httr2::req_perform(req)

  # Extract and return the access token from the response
  purrr::pluck(httr2::resp_body_json(resp), "access_token")
}

#' Create a new test and collect its metadata
#'
#' @param template_id ID of the template to use
#' @return A list containing the new test information and the path to the metadata file
#' @export
create_test_and_collect_metadata <- function(template_id) {
  test_data <- create_new_test(template_id)
  
  if (!is.null(test_data)) {
    metadata <- collect_and_store_test_metadata(test_data)
    
    return(list(
      test_data = test_data,
      metadata = metadata,
      metadata_file = paste0(format(lubridate::today(), "%Y-%m-%d"), "_test_created.csv")
    ))
  } else {
    return(NULL)
  }
}