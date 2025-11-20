ARG R_VER="4.5.1"

FROM rocker/r-ver:${R_VER} AS base
ARG QUARTO_VER="1.8.25"
ARG PANDOC_VER="3.8.2.1"  
ARG CRAN_DATE="2025-11-01"

# Combine rocker scripts and system package installation
RUN /rocker_scripts/setup_R.sh \
    https://packagemanager.posit.co/cran/__linux__/noble/$CRAN_DATE && \
    /rocker_scripts/install_quarto.sh $QUARTO_VER && \
    /rocker_scripts/install_pandoc.sh $PANDOC_VER

# Install system dependencies in single layer
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        libxt6 \
        gdebi-core \
        curl \
        libglpk-dev \
        # Dependency for flextable
        libwebp-dev \
        libarchive13 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Copy R packages list and install
COPY rpackages.txt /tmp/rpackages.txt
RUN install2.r --error --skipinstalled \
        $(cat /tmp/rpackages.txt | tr '\n' ' ') && \
    rm -rf /tmp/downloaded_packages /tmp/rpackages.txt && \
    strip /usr/local/lib/R/site-library/*/libs/*.so

# Install cmdstanr from GitHub and cmdstan in single layer
RUN Rscript -e 'remotes::install_github("stan-dev/cmdstanr@v0.9.0")' && \
    mkdir /opt/cmdstan && \
    Rscript -e "cmdstanr::install_cmdstan(dir = '/opt/cmdstan', cores = 2)" && \
    rm -rf /tmp/* /var/tmp/*

ENV CMDSTAN="/opt/cmdstan"
ENV TZ=America/New_York

FROM base AS development

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install Python, radian, and development tools
COPY install-dev-tools.sh /tmp/install-dev-tools.sh
RUN chmod +x /tmp/install-dev-tools.sh && \
    /tmp/install-dev-tools.sh

ENV PATH="/usr/local/bin:$PATH"

# Install R development packages
RUN install2.r --error \
        languageserver jsonlite rlang && \
    Rscript -e "remotes::install_github('nx10/httpgd@v2.0.4')" && \
    rm -rf /tmp/downloaded_packages /tmp/* /var/tmp/* && \
    strip /usr/local/lib/R/site-library/*/libs/*.so

# Create user in final step
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME


USER $USERNAME
