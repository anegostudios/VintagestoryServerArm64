#!/bin/bash

# Set the default installation directory to the current working directory + "/vintagestory"
DEFAULT_INSTALL_DIR="$(pwd)/vintagestory"

# Check if the machine architecture is ARM or AArch64
if [[ $(uname -m) != "arm"* && $(uname -m) != "aarch64" ]]; then
  echo "Error: This script is intended for ARM-based servers. Your machine does not appear to have an ARM CPU."
  exit 1
fi

# Function to check if a command is available
# Function to check if a command is available
command_exists() {
  which "$1" >/dev/null 2>&1
}

# Function to detect the user's Linux distribution
detect_linux_distribution() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ -n "$ID" ]; then
      echo "$ID"
    elif [ -n "$ID_LIKE" ]; then
      echo "$ID_LIKE"
    fi
  fi
}

# Check if "curl" is installed, if not provide installation instructions based on Linux distribution
if ! command_exists curl; then
  echo "Error: 'curl' is not installed."
  LINUX_DISTRO=$(detect_linux_distribution)
  
  case $LINUX_DISTRO in
    debian|ubuntu)
      echo "You can install 'curl' on Debian/Ubuntu with:"
      echo "sudo apt update"
      echo "sudo apt install curl"
      ;;
    fedora)
      echo "You can install 'curl' on Fedora with:"
      echo "sudo dnf install curl"
      ;;
    centos)
      echo "You can install 'curl' on CentOS with:"
      echo "sudo yum install curl"
      ;;
    *)
      echo "Unsupported Linux distribution. Please install 'curl' manually."
      ;;
  esac
  
  exit 1
fi

# Check if "jq" is installed, if not provide installation instructions based on Linux distribution
if ! command_exists jq; then
  echo "Error: 'jq' is not installed."
  LINUX_DISTRO=$(detect_linux_distribution)
  
  case $LINUX_DISTRO in
    debian|ubuntu)
      echo "You can install 'jq' on Debian/Ubuntu with:"
      echo "sudo apt update"
      echo "sudo apt install jq"
      ;;
    fedora)
      echo "You can install 'jq' on Fedora with:"
      echo "sudo dnf install jq"
      ;;
    centos)
      echo "You can install 'jq' on CentOS with:"
      echo "sudo yum install jq"
      ;;
    *)
      echo "Unsupported Linux distribution. Please install 'jq' manually."
      ;;
  esac
  
  exit 1
fi

# Check if "dotnet" is installed
if ! command_exists dotnet; then
  echo "Error: '.NET SDK' is not installed."
  echo "Please install '.NET SDK' to continue."
  
  # Detect the user's current OS and provide installation instructions
  if [[ $(uname -s) == "Linux" ]]; then
    if [[ $(uname -o) == "GNU/Linux" ]]; then
      echo "You can install .NET SDK on Linux by following the instructions here:"
      echo "https://learn.microsoft.com/en-us/dotnet/core/install/linux"
    else
      echo "Unsupported Linux distribution. You can install .NET SDK on Linux by following the instructions here:"
      echo "https://learn.microsoft.com/en-us/dotnet/core/install/linux"
    fi
  else
    echo "Unsupported OS. You can install .NET SDK by following the instructions here:"
    echo "https://learn.microsoft.com/en-us/dotnet/core/install/"
  fi
  
  exit 1
fi

# Function to display help information
display_help() {
  cat <<EOF
Vintage Story Installation Script
Usage: ./arminstall.sh [OPTIONS]
Options:
  -b, --branch BRANCH        Set the branch (stable, unstable, pre)
  -v, --version VERSION      Set the version (e.g., 1.0.0)
  -d, --directory DIRECTORY  Set the installation directory (default: $DEFAULT_INSTALL_DIR)
  -h, --help                 Show this help message
EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -b|--branch)
      FILES_BRANCH="$2"
      shift
      shift
      ;;
    -v|--version)
      RELEASE_VERSION="$2"
      shift
      shift
      ;;
    -d|--directory)
      INSTALL_DIR="$2"
      shift
      shift
      ;;
    -h|--help)
      display_help  # Display help and exit without further checks
      exit 0
      ;;
    *)
      echo "Invalid argument: $1"
      display_help
      exit 1
      ;;
  esac
done

# Default values
FILES_BRANCH="${FILES_BRANCH:-stable}"
RELEASE_VERSION="${RELEASE_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

declare -A API_URLS=(
  ["stable"]="http://api.vintagestory.at/stable.json"
  ["unstable"]="http://api.vintagestory.at/unstable.json"
  ["pre"]="http://api.vintagestory.at/pre.json"
)

declare -A DOWNLOAD_URLS=(
  ["stable"]="https://cdn.vintagestory.at/gamefiles/stable/vs_server_${RELEASE_VERSION}.tar.gz"
  ["unstable"]="https://account.vintagestory.at/files/unstable/vs_server_${RELEASE_VERSION}.tar.gz"
  ["pre"]="https://cdn.vintagestory.at/gamefiles/pre/vs_server_${RELEASE_VERSION}.tar.gz"
)

API_URL="${API_URLS[$FILES_BRANCH]}"

if [ -z "$API_URL" ]; then
  echo "Invalid branch: $FILES_BRANCH"
  exit 1
fi

if [ "$RELEASE_VERSION" == "latest" ]; then
  DOWNLOAD_URL=$(curl -SsL "$API_URL" | jq -r 'if ([.[]] | .[0].linuxserver.urls.cdn) != null then [.[]] | .[0].linuxserver.urls.cdn else [.[]] | .[0].linuxserver.urls.local end')
else
  DOWNLOAD_URL="https://cdn.vintagestory.at/gamefiles/${FILES_BRANCH}/vs_server_linux-x64_${RELEASE_VERSION}.tar.gz"
fi

echo "API URL: $API_URL"
echo "Download URL: $DOWNLOAD_URL"

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Change the current working directory to the installation directory
cd "$INSTALL_DIR" || exit

curl -o vs_server.tar.gz -L "$DOWNLOAD_URL" # Use -L for redirection
tar -xzf vs_server.tar.gz

#Remove unwanted files
rm -rf VintagestoryServer VintagestoryServer.deps.json VintagestoryServer.dll VintagestoryServer.pdb VintagestoryServer.runtimeconfig.json Lib

# Download the release for ARM64 and extract it

# https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.19.0-rc.6/vs_server_linux-arm64-1.19.tar.gz
ARM64_RELEASE_URL="https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.19.0-rc.6/vs_server_linux-arm64-1.19.tar.gz"
curl -o vs_server_arm64.tar.gz -L "$ARM64_RELEASE_URL" # Use -L for redirection
tar -xzf vs_server_arm64.tar.gz

# Copy the contents of the "server" directory from the extracted files to the server location
cp -r server/* "$INSTALL_DIR/"

# Remove the "server" directory and its contents
rm -rf server

# Remove temporary files
rm -f vs_server.tar.gz vs_server_arm64.tar.gz


echo "-----------------------------------------"
echo "Installation completed"
echo "-----------------------------------------"
