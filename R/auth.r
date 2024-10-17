### auth.R

#' Get Inspera API access token
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