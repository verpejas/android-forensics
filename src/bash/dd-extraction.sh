#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script extracts data from already existing image. It processes the userdata dd image.                 #
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

# Copy the relevant data from the mounted filesystem to the output directory
echo "Extracting data........"
cp -R $MOUNTED_IMG/data/com.android.providers.contacts/databases/ $OUTPUT_DIR/contacts
cp -R $MOUNTED_IMG/data/com.android.providers.telephony/databases/ $OUTPUT_DIR/telephony_mms_sms
cp -R $MOUNTED_IMG/data/com.android.providers.calendar/databases/ $OUTPUT_DIR/calendar
cp -R $MOUNTED_IMG/data/com.sec.android.provider.logsprovider/ $OUTPUT_DIR/callog
cp -R $MOUNTED_IMG/data/com.android.email/databases/ $OUTPUT_DIR/email
cp -R $MOUNTED_IMG/data/com.android.chrome/ $OUTPUT_DIR/chrome
cp -R $MOUNTED_IMG/media/0/DCIM/ $OUTPUT_DIR/DCIM
cp -R $MOUNTED_IMG/media/0/Pictures/ $OUTPUT_DIR/Pictures
cp -R $MOUNTED_IMG/media/0/Download/ $OUTPUT_DIR/downloads

# Fix permissions on extracted files
sudo chown -R $USER: $OUTPUT_DIR

# File counter and message
echo "Extraction succesful! Files are stored in $OUTPUT_DIR and are ready to be analyzed."
echo "Extracted file count:" `find $OUTPUT_DIR/ -type f | wc -l`

# Unmount the image and remove the loopback
sudo umount $MOUNTED_IMG
sudo losetup -d $LOOP_DEV

echo "$MOUNTED_IMG is unmounted and loop device $LOOP_DEV is now removed."