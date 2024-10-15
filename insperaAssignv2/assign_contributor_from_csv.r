# Script to assign contributors to tests using insperaAssignv2 package

# Load the package
library(insperaAssignv2)

# Function to set up the environment
setup_environment <- function() {
  # Check if .env file exists
  if (file.exists(".env")) {
    readRenviron(".env")
  } else {
    stop("Please create a .env file with the required environment variables.")
  }
  
  # Check if required environment variables are set
  required_vars <- c("INSPERA_API_KEY", "TEST_ID_CSV_PATH", "CONTRIBUTORS_CSV_PATH")
  missing_vars <- required_vars[!nzchar(Sys.getenv(required_vars))]
  
  if (length(missing_vars) > 0) {
    stop("Missing environment variables: ", paste(missing_vars, collapse = ", "))
  }
}

# Main function to run the assignment process
run_assignment <- function() {
  cat("Starting the contributor assignment process...\n")
  
  # Set up the environment
  setup_environment()
  
  # Run the assignment function
  tryCatch({
    results <- assign_contributors_from_csv()
    
    # Print results
    cat("\nAssignment Results:\n")
    print(results)
    
    # Summarize results
    successful_assignments <- sum(results$status == 200)
    total_assignments <- nrow(results)
    
    cat("\nSummary:\n")
    cat("Total assignments attempted:", total_assignments, "\n")
    cat("Successful assignments:", successful_assignments, "\n")
    cat("Failed assignments:", total_assignments - successful_assignments, "\n")
    
  }, error = function(e) {
    cat("An error occurred during the assignment process:\n")
    cat(conditionMessage(e), "\n")
  })
}

# Run the assignment process
run_assignment()