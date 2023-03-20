#!/bin/bash

set -e

# Load installation scripts
wget "https://github.com/cmdr2/stable-diffusion-ui/releases/download/v2.5.24/Easy-Diffusion-Linux.zip"
unzip -q Easy-Diffusion-Linux.zip
rm Easy-Diffusion-Linux.zip

# Apply patch on installation
patch ./easy-diffusion/scripts/on_env_start.sh < "./patches-${ED_VERSION}/on_env_start.patch"

echo "Installation files loaded and patched"