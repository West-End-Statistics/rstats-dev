#!/bin/bash
set -e

# Install Python, radian, and development tools
export DEBIAN_FRONTEND=noninteractive

echo "Installing development tools and Python..."
apt-get update
apt-get -y install --no-install-recommends \
    software-properties-common \
    git \
    xz-utils \
    sudo

echo "Adding Python PPA and installing Python 3.11..."
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get -y install --no-install-recommends \
    python3.11 \
    python3-pip \
    pipx

echo "Installing radian..."
PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install radian

ARF_VER="0.6.0"
echo "Installing arf ${ARF_VER} (modern R console)..."
ARF_TARGET="$(uname -m)-unknown-linux-gnu"
curl -fsSL "https://github.com/eitsupi/arf/releases/download/v${ARF_VER}/arf-console-${ARF_TARGET}.tar.xz" \
    | tar -xJ -C /usr/local/bin --strip-components=1 "arf-console-${ARF_TARGET}/arf"

echo "Installing LibreOffice Writer (for .docx to PDF rendering)..."
apt-get -y install --no-install-recommends \
    libreoffice-writer \
    fonts-liberation

echo "Installing GitHub CLI..."
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list
apt-get update
apt-get -y install --no-install-recommends gh

echo "Cleaning up..."
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "Development tools installation complete!"