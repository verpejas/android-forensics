#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script works on devices without a screen lock. It requires enabled USB debugging in developer options.#
# It reboots into download mode automatically and flashes the TWRP recovery image for ADB comunication.      #
##############################################################################################################
"

# Create and set the path to data extraction directory, mounted image dir, set working directory and dd image file path.
CWD=$(pwd)
mkdir -p $CWD/extracted_data
mkdir -p $CWD/mounted_dd
DD_IMAGE_PATH="$CWD/userdata.img"
OUTPUT_DIR="$CWD/extracted_data"
MOUNTED_IMG="$CWD/mounted_dd"
STOCK_RECOVERY="$CWD/recovery/stock.img"
CUSTOM_RECOVERY="$CWD/recovery/custom.img"

# Printing importand paths.
echo -e "Important paths: \n
Userdata dd image path: $DD_IMAGE_PATH
Data extraction directory: $OUTPUT_DIR \n\n"

# Check for ADB connection
echo "I will check for connected devices. Please make sure "USB Debugging" is turned ON on the target device before continuing."
read -n 1 -s -r -p $'Press any key after you connected your device. Authorize the connection in the dialog box on target.'
adb devices >/dev/null # we call the command twice to "force" the authorization screen to appear on the device
adb devices
read -n 1 -s -r -p $'Check if the correct device is being detected. Afer confirming, press any key to reboot into "Download mode"...\n'

# Reboot into download mode using ADB
adb reboot download
read -n 1 -s -r -p $'Press any key after the device reboots into Download mode. Ensure you are using a good quality USB cable for the flashing!'

# Flash TWRP recovery using heimdall
echo "Flashing the TWRP custom recovery to the device via Heimdall"
heimdall flash --RECOVERY $CUSTOM_RECOVERY --no-reboot

# Prompt the user to reboot into TWRP recovery manually
read -n 1 -s -r -p $'Hold volume_up + home + power until device reboots into TWRP. Press any key to continue the script...\n'

# Check if the device is recognized in ADB while booted into TWRP recovery
adb devices
read -n 1 -s -r -p $'Check if the correct device is being detected. Afer confirming, press any key to continue the script"...\n'

# Prompt the user to format the external sdcard
read -n 1 -s -r -p $'Format the external_sd with EXT4 or exFAT file system, to overcome FAT32 4gb file limitation\n
This step is manual to ensure the right partition is being formatted. In TWRP enter the wipe menu and select external_sd.
Choose the option "Repair or Change filesystem". Select "Change File System", then EXT4 or exFAT and swipe to confirm.\n\n
You can ignore this step if the card is already formatted in EXT4/exFAT, but flwaless and performant copy cannot be guaranteed!
Press any key to continue the script"...\n'

# Print the partition table to the console
echo "Relevant partitions for analysis:"
adb shell df -a -h

# Prompt the user to enter the partition they want to extract
read -p "Enter the partition you want to extract (format: mmcblk0pXX): " partition_name

# Dump the selected partition to image and save it to the Android device's external sdcard
echo "Dumping partition $partition_name to the external SD-card on the device"
adb shell "dd if=/dev/block/$partition_name of=/external_sd/userdata.img"

# Adb uses a 32-bit unsigned integer to represent the size of the file being transferred,
# which limits the size of the file that can be displayed to just under 4.3 GB (4,294,967,295). Once the transferred file reaches this size,
# adb will no longer be able to accurately report the percentage progress of the transfer, and will instead display byte count.
# The file transfer will still work as it should, but without proper tty feedback

# Pull the image from the Android device to the working directory
echo "Pulling the $partition_name image to $CWD"
adb pull /external_sd/userdata.img $CWD

# Flash stock recovery back to leave the phone in official state
adb reboot download
read -n 1 -s -r -p $'Press any key after the device reboots into Download mode. Ensure you are using a good quality USB cable for the flashing!\n'
heimdall flash --RECOVERY $STOCK_RECOVERY
echo "Stock recovery flashed, phone restored to factory state! Rebooting now!"

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
