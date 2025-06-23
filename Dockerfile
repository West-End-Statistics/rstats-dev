ARG R_VER="4.5.1"
ARG QUARTO_VER="1.7.31"
ARG PANDOC_VER="3.7.0.1"

FROM rocker/r-ver:${R_VER} AS base
RUN /rocker_scripts/setup_R.sh \
  https://packagemanager.posit.co/cran/__linux__/noble/2025-06-15
# https://code.visualstudio.com/docs/devcontainers/create-dev-container#:~:text=Note%3A%20The%20DEBIAN_FRONTEND%20export%20avoids%20warnings%20when%20you%20go%20on%20to%20work%20with%20your%20container.
RUN /rocker_scripts/install_quarto.sh $QUARTO_VER
RUN /rocker_scripts/install_pandoc.sh $PANDOC_VER
RUN apt-get update --fix-missing && export DEBIAN_FRONTEND=noninteractive
# https://notes.rmhogervorst.nl/post/2020/09/23/solving-libxt-so-6-cannot-open-shared-object-in-grdevices-grsoftversion/
RUN apt-get install -y --no-install-recommends \
  libxt6 \
  gdebi-core curl \
  # for igraph 
  libglpk-dev \
  # for ggalluvial
  libarchive13 \
  && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN install2.r --error  --skipinstalled \
  bayesDP \
  bayesplot \
  broom \
  broom.mixed \
  brms \
  checkmate \
  collapse \
  crew \
  dplyr \
  emmeans \
  flextable \
  ggplot2 \
  ggalluvial \
  gsDesign \
  gtsummary \
  haven \
  here \
  janitor \
  knitr \
  labelled \
  lme4 \
  lmerTest \
  memoise \
  microbenchmark \
  mvtnorm \
  mmrm \
  pander \
  plotly \
  purrr \
  quarto \
  readr \
  readxl \
  remotes \
  renv \
  rmarkdown \
  rpact \
  rstan \
  skimr \
  tarchetypes \
  targets\
  tibble \
  tidyr \
  tree \
  && rm -rf /tmp/downloaded_packages \
  && strip /usr/local/lib/R/site-library/*/libs/*.so
RUN Rscript -e 'remotes::install_github("stan-dev/cmdstanr@v0.9.0")'
RUN Rscript -e 'cmdstanr::install_cmdstan(cores = 2)'  

FROM base AS development
# https://www.makeuseof.com/install-python-ubuntu/
# install radian and python
RUN apt-get update && apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa && apt update
RUN apt-get -y install python3.11 python3-pip git pipx
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install radian
ENV PATH="/usr/local/bin:$PATH"

# end install radian

# Packages needed for development with vscode
RUN install2.r --error \
  languageserver jsonlite rlang \
  && rm -rf /tmp/downloaded_packages \
  && strip /usr/local/lib/R/site-library/*/libs/*.so
# there are often issues with httpgd getting taken down from CRAN
RUN Rscript -e "remotes::install_github('nx10/httpgd@v2.0.4')"

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME
#RUN pipx install radian

