#!/usr/bin/env Rscript

# Test script to verify key R packages can be loaded
# This script should be run inside the Docker container

test_package_loading <- function() {
  cat("Testing R package loading...\n")


  
  # List of critical packages to test
  packages_to_test <- readLines(here::here("rpackages.txt"));
  
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




test_user_lib_installation <- function() {
  cat("Testing user R library setup...\n")

  r_libs_user <- Sys.getenv("R_LIBS_USER")

  if (r_libs_user == "") {
    cat("\u2717 R_LIBS_USER is not set\n")
    quit(status = 1)
  }
  cat("\u2713 R_LIBS_USER is set:", r_libs_user, "\n")

  if (!dir.exists(r_libs_user)) {
    cat("\u2717 R_LIBS_USER directory does not exist:", r_libs_user, "\n")
    quit(status = 1)
  }
  cat("\u2713 R_LIBS_USER directory exists\n")

  if (!r_libs_user %in% .libPaths()) {
    cat("\u2717 R_LIBS_USER is not in .libPaths()\n")
    cat("  .libPaths():", paste(.libPaths(), collapse = ", "), "\n")
    quit(status = 1)
  }
  cat("\u2713 R_LIBS_USER is in .libPaths()\n")

  if (file.access(r_libs_user, mode = 2) != 0) {
    cat("\u2717 R_LIBS_USER directory is not writable\n")
    quit(status = 1)
  }
  cat("\u2713 R_LIBS_USER directory is writable\n")

  cat("\n\u2713 User R library setup is correct!\n")
}


# Run the tests
test_package_loading()
test_user_lib_installation()

