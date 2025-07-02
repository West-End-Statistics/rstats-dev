#!/bin/bash
set -e

# Install Python, radian, and development tools
export DEBIAN_FRONTEND=noninteractive

echo "Installing development tools and Python..."
apt-get update
apt-get -y install --no-install-recommends \
    software-properties-common \
    git \
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

echo "Cleaning up..."
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "Development tools installation complete!"