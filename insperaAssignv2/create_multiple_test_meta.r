library(testthat)
library(insperaAssignv2)
library(mockery)

# Create a temporary directory for test files
temp_dir <- tempdir()

# Create mock CSV files
test_id_csv <- file.path(temp_dir, "test_ids.csv")
contributors_csv <- file.path(temp_dir, "contributors.csv")

# Write mock data to CSV files
write.csv(data.frame(
  AssessmentRunId = c(283543578, 283543586, 283543594),
  ExternalTestId = c(NA, NA, NA),
  Title = c(NA, NA, NA),
  StartTime = c(NA, NA, NA),
  EndTime = c(NA, NA, NA),
  Status = c("created", "created", "created")
), test_id_csv, row.names = FALSE)

write.csv(data.frame(
  contributor = c("contributor1@example.com", "contributor2@example.com")
), contributors_csv, row.names = FALSE)

# Set up mock environment variables
Sys.setenv(
  INSPERA_ACCESS_TOKEN = "mock_token",
  TEST_ID_CSV_PATH = test_id_csv,
  CONTRIBUTORS_CSV_PATH = contributors_csv
)

# Mock the httr2::req_perform function
mock_req_perform <- mock(list(status_code = 200))

test_that("assign_contributors_from_csv works correctly", {
  # Replace the actual req_perform with our mock version
  with_mock(
    "httr2::req_perform" = mock_req_perform,
    {
      result <- insperaAssignv2::assign_contributors_from_csv()
      
      # Check that the function returns the expected structure
      expect_s3_class(result, "data.frame")
      expect_equal(nrow(result), 3)
      expect_equal(names(result), c("test_id", "status"))
      
      # Check that all statuses are 200 (as mocked)
      expect_true(all(result$status == 200))
      
      # Check that all test IDs from the CSV are present
      expect_setequal(result$test_id, c(283543578, 283543586, 283543594))
      
      # Check that req_perform was called the correct number of times
      expect_equal(length(mock_req_perform$calls), 3)
      
      # Check that the access token is used correctly
      expect_true(all(grepl("Bearer mock_token", as.character(mock_req_perform$calls))))
    }
  )
})

# Clean up
unlink(test_id_csv)
unlink(contributors_csv)