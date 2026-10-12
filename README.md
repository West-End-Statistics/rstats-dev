# rstats-dev

R development image for West End Statistics, published to Docker Hub as
[`westendstatistics/rstats-dev`](https://hub.docker.com/r/westendstatistics/rstats-dev).

## What's in it

- R (from `rocker/r-ver`), Quarto and Pandoc, at the versions pinned at the top of `Dockerfile`
- CRAN packages listed in `rpackages.txt`, installed from a dated Posit Package Manager snapshot (`CRAN_DATE`)
- `cmdstanr` and CmdStan (`/opt/cmdstan`)
- Development target only: Python, `radian`, `languageserver`, `httpgd`, GitHub CLI (`gh`), LibreOffice Writer (for rendering `.docx` to PDF), and a non-root `vscode` user

## Tags

Each push to `main` publishes `r<R version>-<YYYYMMDD>` (the date of the last commit), plus `r<R version>` and `latest`.
Pin the dated tag in project repos, e.g. `FROM westendstatistics/rstats-dev:r4.5.3-20260528`.

## Updating

Change the version ARGs at the top of `Dockerfile` (`R_VER`, `QUARTO_VER`, `PANDOC_VER`, `CRAN_DATE`), or add a package name to `rpackages.txt`, then run:

```sh
./test.sh
```

This builds the image and checks that every package in `rpackages.txt` and `cmdstanr` load.
