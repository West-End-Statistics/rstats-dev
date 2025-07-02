#!/bin/bash

# Test script to build Docker image and run tests
set -e

# Use podman if docker is not available
if ! command -v docker &> /dev/null; then
    shopt -s expand_aliases
    alias docker=podman
fi

echo "Building main Docker image..."
docker build -t rstats-dev:latest .

echo "Building test image..."
docker build -f tests/Dockerfile.test -t rstats-dev:test .

echo "Running tests..."
docker run --rm rstats-dev:test

echo "All tests passed!"