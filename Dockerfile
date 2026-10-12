ARG R_VER="4.5.3"

FROM rocker/r-ver:${R_VER} AS base
ARG QUARTO_VER="1.10.19"
ARG PANDOC_VER="3.12.1"
ARG CRAN_DATE="2026-09-30"

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
        # SSH seems to have disappeared at some point - useful for dev
        openssh-client \
        libarchive13 \
        libuv1 \
        # LibreOffice for rendering .docx output to PDF/PNG (tlf-review skill)
        libreoffice-writer \
        fonts-liberation && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
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
    Rscript -e "remotes::install_github('nx10/httpgd@v2.1.4')" && \
    rm -rf /tmp/downloaded_packages /tmp/* /var/tmp/* && \
    strip /usr/local/lib/R/site-library/*/libs/*.so

# Create user in final step
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME


USER $USERNAME

# Create R_LIBS_USER directory so packages can be installed without root
RUN Rscript -e "dir.create(path = Sys.getenv('R_LIBS_USER'), showWarnings = FALSE, recursive = TRUE)" && \
    echo '.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))' >> /home/$USERNAME/.Rprofile
