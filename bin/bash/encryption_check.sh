#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script checks if your device has force-encrypt enabled. If it is enabled,                             #
# unfortunately this tool will not be able to help with accessing any stored data.                           #
# If the device does not have a screen lock, you can enable usb debugging and check the encryption status    #
##############################################################################################################
"
# Check for ADB connection
echo "I will check for connected devices. Please make sure "USB Debugging" is turned ON on the target device before continuing."
read -n 1 -s -r -p $'Press any key after you connected your device. Authorize the connection in the dialog box on target.'
adb devices >/dev/null # we call the command twice to "force" the authorization screen to appear on the device
adb devices
read -n 1 -s -r -p $'Check if the correct device is being detected. Afer confirming, press any key to check the encryption status"...\n'

echo "Your device is" `adb shell getprop ro.crypto.state`
