# multiple_test_creation_script.R
#WARNING: this test script only makes tests if the test id numbre is new, if not it gets updated. .env num-tests var controls this
library(InspeRaAssign)
library(dotenv)
library(readr)
library(lubridate)
library(futile.logger)

# Initialize logging
flog.appender(appender.file("test_creation.log"))
flog.threshold(INFO)

# Load environment variables
load_dot_env()

# Function to get environment variable with default value
get_env_var <- function(var_name, default_value) {
  value <- Sys.getenv(var_name)
  if (value == "") {
    flog.warn("Environment variable %s is not set. Using default value: %s", var_name, default_value)
    return(default_value)
  }
  return(value)
}

# Get environment variables
api_key <- get_env_var("INSPERA_API_KEY", "")
template_id <- get_env_var("INSPERA_TEMPLATE_ID", "")
num_tests <- as.numeric(get_env_var("NUM_TESTS", "5"))
title_prefix <- get_env_var("TITLE_PREFIX", "Exam")

# Validate required environment variables
if (api_key == "" || template_id == "") {
  stop("INSPERA_API_KEY and INSPERA_TEMPLATE_ID must be set in the .env file")
}

# Set up test parameters
start_time <- floor_date(now() + days(1), "day") + hours(9)
duration <- 120  # 120 minutes
gap_between_tests <- 15  # 15 minutes gap between tests

# Function to create tests and collect metadata
create_tests_and_collect_metadata <- function() {
  flog.info("Starting test creation process")
  
  metadata <- data.frame(
    assessment_run_id = character(),
    external_test_id = character(),
    title = character(),
    start_time = character(),
    end_time = character(),
    status = character(),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:num_tests) {
    test_start_time <- start_time + minutes((i-1) * (duration + gap_between_tests))
    test_end_time <- test_start_time + minutes(duration)
    
    external_test_id <- sprintf("test_%03d", i)
    title <- sprintf("%s %03d", title_prefix, i)
    
    flog.info("Creating test %d of %d", i, num_tests)
    flog.debug("Parameters: external_test_id=%s, title=%s, start_time=%s, end_time=%s", 
               external_test_id, title, format(test_start_time, "%Y-%m-%dT%H:%M:%SZ"), format(test_end_time, "%Y-%m-%dT%H:%M:%SZ"))
    
    result <- tryCatch({
      create_new_test(
        template_id = template_id,
        external_test_id = external_test_id,
        title = title,
        start_time = format(test_start_time, "%Y-%m-%dT%H:%M:%SZ"),
        end_time = format(test_end_time, "%Y-%m-%dT%H:%M:%SZ"),
        duration = duration
      )
    }, error = function(e) {
      flog.error("Error creating test: %s", e$message)
      return(NULL)
    })
    
    if (!is.null(result)) {
      flog.info("Test created successfully: AssessmentRunID=%s, Status=%s", result$assessmentRunId, result$status)
      
      metadata <- rbind(metadata, data.frame(
        assessment_run_id = result$assessmentRunId,
        external_test_id = external_test_id,
        title = title,
        start_time = format(test_start_time, "%Y-%m-%d %H:%M:%S"),
        end_time = format(test_end_time, "%Y-%m-%d %H:%M:%S"),
        status = result$status,
        stringsAsFactors = FALSE
      ))
    } else {
      flog.warn("Failed to create test %d", i)
    }
  }
  
  return(metadata)
}

# Main execution
main <- function() {
  flog.info("Starting multiple test creation script")
  
  flog.info("Parameters:")
  flog.info("Number of tests: %d", num_tests)
  flog.info("Template ID: %s", template_id)
  flog.info("Title prefix: %s", title_prefix)
  flog.info("Start time: %s", format(start_time, "%Y-%m-%dT%H:%M:%SZ"))
  flog.info("Test duration: %d minutes", duration)
  flog.info("Gap between tests: %d minutes", gap_between_tests)
  
  metadata <- create_tests_and_collect_metadata()
  
  if (nrow(metadata) > 0) {
    output_file <- paste0(format(now(), "%Y-%m-%d_%H-%M-%S"), "_tests_created.csv")
    write_csv(metadata, output_file)
    flog.info("Test metadata stored in file: %s", output_file)
    print(metadata)
  } else {
    flog.warn("No tests were created successfully")
  }
  
  flog.info("Multiple test creation script completed")
}

# Run the main function
main()