#!/bin/bash
clear
##############################################################################################################
# This script is a menu/launcher with choices for all the options of the program. It launches the scripts.  #
##############################################################################################################

# Define options
options=("Automated extraction for devices without a screen lock"
         "Manual extraction for screen locked phones"
         "Pulling data from device already booted into TWRP (should also work on rooted devices)"
         "Extracting data from an existing userdata DD image"
         "Database extractor from db files"
         "Install required prerequisites (Android Debug Bridge, sqlite3 and Heimdall flashtool)"
         "Check if your device has force-encrypt enabled"
         "Mount the dd image"
         "Create SHA-512 hashes for extracted data"
         "Exit")

# Define function to run selected option and exit after completion
run_option_and_exit() {
  case $1 in
    1)
      ./bash/automatic-no_lock.sh
      ;;
    2)
      ./bash/manual-lock.sh
      ;;
    3)
      ./bash/twrp-pull.sh
      ;;
    4)
      ./bash/dd-extraction.sh
      ;;
    5)
      ./bash/db_extractor.sh
      ;;
    6)
      ./bash/prerequisite_installer.sh
      ;;
    7)
      ./bash/encryption_check.sh
      ;;
    8)
     ./bash/dd_mounting.sh
     ;;
    9)
     ./bash/sha-512_hashing.sh
     ;;
    10)
      clear
      exit
      ;;
    *)
      echo "Invalid option, please try again"
      return 1
      ;;
  esac
  echo "Operations completed."
  read -n 1 -s -r -p "Press any key to return to the menu..."
  clear
}

# Display welcome message
echo -e "Welcome to my data extractor and analyzer!\n
To ensure proper operation, install all required packages using option 6 on the menu before proceeding.\n
This tool is tested and developed with Samsung devices in mind.
For non-Samsung devices, options 3-10 are viable.
This tool should work on every android device that does NOT have force-encrypt enabled.\n
This data extractor DOES NOT require root access/SU binary on the system partition.
It uses a custom recovery called TWRP to gain access to the storage and pull the image.\n
Recovery images provided with the script are meant only for Samsung Galaxy S3 Neo+ (GT-I9301I)!
If you wish to use this script with other Samsung device, simply replace both recovery images
in the ./recovery folder with the correct ones for your device, and rename them accordingly.
Stock recovery can be extracted from .tar.md5 firmware file, while twrp image can be found at https://twrp.me/

Enter your sudo password to elevate permissions.\n"

if ! sudo -vk; then
  echo "Authentication failed. Exiting..."
  exit 1
fi
echo "Authentication succesful!"
read -n 1 -s -r -p "Press any key to enter the menu..."
clear

#Display the menu
while true; do
  echo -e "\nSelect an option (1-10):\n"
  for i in "${!options[@]}"; do
    echo "$((i+1)). ${options[i]}"
  done
  echo

  # Get user input
  read -p "Enter your choice: " choice

  # Run selected option and exit after completion
  run_option_and_exit "$choice"
done
