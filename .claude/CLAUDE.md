# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A Docker image for R statistical development, published to Docker Hub as `westendstatistics/rstats-dev`. The image bundles a pinned R version, Quarto, Pandoc, a large set of CRAN packages (from a Posit Package Manager snapshot), and CmdStan/cmdstanr for Bayesian modeling.

## Build & Test

`/usr/local/bin/docker` is a podman wrapper. Always prepend `/usr/local/bin` to PATH so it takes precedence over the real Docker CLI at `/usr/bin/docker` (which has no running daemon).

```bash
# Build image and run all tests
PATH="/usr/local/bin:$PATH" ./test.sh

# Build only the base image
PATH="/usr/local/bin:$PATH" docker build -t rstats-dev:latest .

# Build only the development target
PATH="/usr/local/bin:$PATH" docker build --target development -t rstats-dev:dev .

# Run tests manually against an already-built image
PATH="/usr/local/bin:$PATH" docker build -f tests/Dockerfile.test -t rstats-dev:test .
PATH="/usr/local/bin:$PATH" docker run --rm rstats-dev:test
```

## Key Version Pins

All version ARGs are at the top of `Dockerfile`:
- `R_VER` — R version (from `rocker/r-ver`)
- `QUARTO_VER` — Quarto version
- `PANDOC_VER` — Pandoc version
- `CRAN_DATE` — Posit Package Manager CRAN snapshot date (controls all CRAN package versions)

To update versions, change these ARGs. The CI workflow auto-detects `R_VER` to build the Docker tag.

## Adding/Removing R Packages

Edit `rpackages.txt` — one package name per line. Packages are installed via `install2.r --skipinstalled` at build time. The test suite (`tests/test_packages.R`) loads every package in this file to verify installation.

`cmdstanr` is installed separately from GitHub (`stan-dev/cmdstanr`) with CmdStan in `/opt/cmdstan` and `$CMDSTAN` env var pointing there.

## Docker Image Architecture

The Dockerfile uses a two-stage build:

1. **`base`** — Production image: R + system deps + all CRAN packages + cmdstanr/CmdStan. Timezone set to `America/New_York`.
2. **`development`** (extends `base`) — Adds Python 3.11, radian (R REPL), `languageserver`, `httpgd`, git, sudo, and a non-root `vscode` user (UID 1000). User's `R_LIBS_USER` is created and prepended to `.libPaths()` so packages can be installed without root.

## CI/CD

GitHub Actions (`.github/workflows/docker-publish.yml`) builds and pushes on every push to `main`:
- Tags: `r{R_VER}-{YYYYMMDD}`, `r{R_VER}` (latest only), `latest` (main only)
- PRs build but do not push
- Requires `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
