#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script mounts the extracted dd image for further investigation. It processes the userdata dd image.   #
##############################################################################################################
"

# Set or create required variables and directories
CWD=$(pwd)
echo "Type in the required path to the image, or drag-n-drop it to the terminal window."
read -p "Enter the path to the DD image : " DD_IMAGE_PATH
mkdir -p $CWD/extracted_data
mkdir -p $CWD/mounted_dd
OUTPUT_DIR="$CWD/extracted_data"
MOUNTED_IMG="$CWD/mounted_dd"

# Startup message, telling the user importand paths.
echo -e "Important paths:
Userdata dd image path: $DD_IMAGE_PATH
Data extraction directory: $OUTPUT_DIR \n\n"

# Create a loopback device for the image, and fix permissions
echo "Reauthentication may be required to create a loopback device"
LOOP_DEV=$(sudo losetup --find --show $DD_IMAGE_PATH)
sudo mount $LOOP_DEV $MOUNTED_IMG
sudo chown -R $USER: $MOUNTED_IMG

# Print the loopback device name for debugging
echo "Loopback device: $LOOP_DEV"
read -n 1 -s -r -p $'Image mounted! Press any key after You have copied required data to output directory\n'

# Fix permissions on extracted files
sudo chown -R $USER: $OUTPUT_DIR

# File counter and message
echo "Extraction succesful! Files are stored in $OUTPUT_DIR and are ready to be analyzed."
echo "Extracted file count:" `find $OUTPUT_DIR/ -type f | wc -l`

# Unmount the image and remove the loopback
sudo umount $MOUNTED_IMG
sudo losetup -d $LOOP_DEV

echo "$MOUNTED_IMG is unmounted and loop device $LOOP_DEV is now removed."