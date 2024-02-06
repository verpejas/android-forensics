#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script installs all required components and prerequisites for my tool to work properly.               #
# It will update the package list and install android-sdk-platform-tools, heimdall-flash and sqlite3         #
##############################################################################################################
"

# Display menu and prompt for user input
echo "Please choose your OS:"
echo "1) Debian-based (Ubuntu, Pop!OS, Mint...)"
echo "2) Fedora-based (RHEL, Fedora)"
echo "3) Arch-based (Arch, Manjaro...)"
echo "4) SUSE-based (OpenSUSE, SUSE Enterprise Linux)"
echo "5) Other distro with package manager different than apt, dnf, zypper or pacman"
read -p "Select an option (1-4): " choice
echo -e "Installing packages\n"

# Check user input and install required packages accordingly
case "$choice" in
  1)
    # Debian-based
    sudo apt-get update
    yes | sudo apt install heimdall-flash android-sdk-platform-tools sqlite3
    echo "The required software was installed on your Debian-based system. You may now proceed with the script"
    ;;
  2)
    # Fedora-based
    sudo dnf update
    yes | sudo dnf install heimdall-flash android-tools sqlite
    echo "The required software was installed on your Fedora-based system. You may now proceed with the script"
    ;;
  3)
    # Arch-based
    sudo pacman -Syu
    yes | sudo pacman -S heimdall android-tools sqlite
    echo "The required software was installed on your Arch-based system. You may now proceed with the script"
    ;;
 4)
    # SUSE-based
    sudo zypper refresh
    sudo zypper --non-interactive install heimdall android-tools sqlite3
    echo "The required software was installed on your SUSE-based system. You may now proceed with the script"
    ;;
  5)
    # Other distro with a different package manager
    echo "Please install the following packages manually using your package manager:"
    echo " - heimdall-flash"
    echo " - android-sdk-platform-tools"
    echo " - sqlite3"
    ;;
  *)
    # Invalid input
    echo "Invalid input. Please enter a number from 1 to 4."
    ;;
esac
