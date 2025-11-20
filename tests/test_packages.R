#!/usr/bin/env Rscript

# Test script to verify key R packages can be loaded
# This script should be run inside the Docker container

test_package_loading <- function() {
  cat("Testing R package loading...\n")
  
  # List of critical packages to test
  packages_to_test <- readLines(here::here("rpackages.txt"))
  
  failed_packages <- c()
  
  for (pkg in packages_to_test) {
    tryCatch({
      library(pkg, character.only = TRUE)
      cat("✓", pkg, "loaded successfully\n")
    }, error = function(e) {
      cat("✗", pkg, "failed to load:", e$message, "\n")
      failed_packages <<- c(failed_packages, pkg)
    })
  }
  
  if (length(failed_packages) > 0) {
    cat("\n✗ Failed packages:", paste(failed_packages, collapse = ", "), "\n")
    quit(status = 1)
  }
  
  cat("\n✓ All packages loaded successfully!\n")
}

# Run the tests
test_package_loading()