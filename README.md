# InspeRaAssign

InspeRaAssign is an R package designed to interact with the Inspera API for assigning contributors to tests.

## Features

- Obtain access tokens from the Inspera API
- Assign contributors to tests using test IDs
- Load test IDs and contributor information from CSV files
- Batch assignment of contributors to multiple tests

## Installation

You can install InspeRaAssign directly from GitHub using the `devtools` package:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install InspeRaAssign
devtools::install_github("ToolsCollectiveR/InspeRaAssign")
```

## Usage
Here's a basic example of how to use InspeRaAssign:
```r
library(InspeRaAssign)

# Set up environment variables
Sys.setenv(INSPERA_API_KEY = "your_api_key_here")
Sys.setenv(TEST_ID_CSV_PATH = "path/to/your/test_ids.csv")
Sys.setenv(CONTRIBUTORS_CSV_PATH = "path/to/your/contributors.csv")

# Assign contributors from CSV files
results <- assign_contributors_from_csv()

# Print results
print(results)
```

## CSV File Formats
Test IDs CSV
The Test IDs CSV should have a column named "AssessmentRunId" containing the test IDs.

Example:
```csv
AssessmentRunId
12345
67890
```

# Contributors CSV
The Contributors CSV should have columns named "contributor" and "committee".

Example:
```csv
contributor,committee
john.doe@example.com,Committee A
jane.smith@example.com,Committee B
```
## Environment Variables
The package uses the following environment variables:

INSPERA_API_KEY: Your Inspera API key
TEST_ID_CSV_PATH: Path to the CSV file containing test IDs
CONTRIBUTORS_CSV_PATH: Path to the CSV file containing contributor information
## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing
Contributions to InspeRaAssign are welcome! Please feel free to submit a Pull Request.