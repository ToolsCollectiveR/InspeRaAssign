# test_creation_script.R

library(insperaAssignv2)
library(dotenv)
library(readr)

# Load environment variables
load_dot_env()

# Fetch template_id from .env
template_id <- Sys.getenv("INSPERA_TEMPLATE_ID")

# Validate template_id
if (template_id == "") {
  stop("INSPERA_TEMPLATE_ID is not set in the .env file")
}

# Test parameters
external_test_id <- "test_002"  # Replace with a unique external test ID
title <- "Test Exam 001"
start_time <- "2023-06-01T09:00:00Z"
end_time <- "2023-06-01T11:00:00Z"
duration <- 120  # in minutes

cat("Creating test using template ID:", template_id, "\n\n")

# Call the function
result <- create_new_test(
  template_id = template_id,
  external_test_id = external_test_id,
  title = title,
  start_time = start_time,
  end_time = end_time,
  duration = duration
)

# Check the result
if (!is.null(result)) {
  cat("Test created successfully!\n")
  cat("Assessment Run ID:", result$assessmentRunId, "\n")
  cat("Status:", result$status, "\n")
  print(result)  # Print the entire result for inspection

  # Create metadata dataframe
  metadata <- data.frame(
    assessmentRunId = result$assessmentRunId,
    externalTestId = external_test_id,
    title = title,
    startTime = start_time,
    endTime = end_time,
    status = result$status,
    stringsAsFactors = FALSE
  )

  # Save metadata to CSV
  today_date <- format(Sys.Date(), "%Y-%m-%d")
  metadata_file <- paste0(today_date, "_test_created.csv")
  write_csv(metadata, metadata_file)

  cat("\nMetadata file created:", metadata_file, "\n")
  print(metadata)
} else {
  cat("Failed to create test.\n")
}