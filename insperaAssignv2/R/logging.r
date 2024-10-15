### logging.R

#' Configure logging for the package
#'
#' Sets up the logging configuration to log messages to both the console and a log file.
#' @importFrom futile.logger flog.appender appender.tee flog.threshold flog.layout layout.simple flog.info flog.warn flog.error
configure_logging <- function() {
  tryCatch({
    # Use tempdir() for a guaranteed writable location
    log_file <- file.path(tempdir(), "insperaAssign.log")
    
    # Configure the logger to write to both the console and the log file
    futile.logger::flog.appender(futile.logger::appender.tee(log_file))
    
    # Set the logging threshold to 'INFO'
    futile.logger::flog.threshold(futile.logger::INFO)
    
    # Use a simple layout for log messages
    futile.logger::flog.layout(futile.logger::layout.simple)
    
    futile.logger::flog.info("Logging configured successfully. Log file: %s", log_file)
  }, error = function(e) {
    warning("Error in configure_logging: ", conditionMessage(e))
  })
}

#' Internal function to log package startup messages
#'
#' @param libname The library name
#' @param pkgname The package name
#' @importFrom dotenv load_dot_env
.onLoad <- function(libname, pkgname) {
  tryCatch({
    # Attempt to configure logging
    configure_logging()
    
    futile.logger::flog.info("Starting .onLoad function")
    
    futile.logger::flog.info("Attempting to load .env file")
    env_file <- system.file(".env", package = "insperaAssignv2")
    if (file.exists(env_file)) {
      dotenv::load_dot_env(env_file)
      futile.logger::flog.info(".env file loaded successfully")
    } else {
      futile.logger::flog.warn(".env file does not exist. Proceeding without loading environment variables.")
    }
    
    futile.logger::flog.info("Finished .onLoad function: insperaAssignv2 package loaded successfully")
  }, error = function(e) {
    warning("Error in .onLoad: ", conditionMessage(e))
  })
}