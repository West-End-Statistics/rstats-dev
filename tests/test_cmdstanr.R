#!/usr/bin/env Rscript

# Test script to verify cmdstanr package loads and works correctly
# This script should be run inside the Docker container

test_cmdstanr_load <- function() {
  cat("Testing cmdstanr package loading...\n")
  
  # Test 1: Load cmdstanr package
  tryCatch({
    library(cmdstanr)
    cat("✓ cmdstanr package loaded successfully\n")
  }, error = function(e) {
    cat("✗ Failed to load cmdstanr package:", e$message, "\n")
    quit(status = 1)
  })
  
  # Test 2: Check cmdstan installation
  tryCatch({
    cmdstan_path <- cmdstan_path()
    cat("✓ CmdStan path found:", cmdstan_path, "\n")
  }, error = function(e) {
    cat("✗ Failed to find CmdStan installation:", e$message, "\n")
    quit(status = 1)
  })
  
  # Test 3: Check cmdstan version
  tryCatch({
    version <- cmdstan_version()
    cat("✓ CmdStan version:", version, "\n")
  }, error = function(e) {
    cat("✗ Failed to get CmdStan version:", e$message, "\n")
    quit(status = 1)
  })
  
  # Test 4: Try to compile a simple model
  tryCatch({
    # Simple Stan model code
    stan_code <- "
    parameters {
      real theta;
    }
    model {
      theta ~ normal(0, 1);
    }
    "
    
    # Write temporary Stan file
    temp_file <- tempfile(fileext = ".stan")
    writeLines(stan_code, temp_file)
    
    # Try to compile
    mod <- cmdstan_model(temp_file)
    cat("✓ Successfully compiled a simple Stan model\n")
    
    # Clean up
    unlink(temp_file)
    
  }, error = function(e) {
    cat("✗ Failed to compile Stan model:", e$message, "\n")
    quit(status = 1)
  })
  
  cat("✓ All cmdstanr tests passed!\n")
}

# Run the tests
test_cmdstanr_load()