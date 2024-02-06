#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script creates SHA-512 hashes for the data in extracted_data folder, to ensure validity of the data.  #
##############################################################################################################
"

# Set the directory to hash
CWD=$(pwd)
OUTPUT_DIR="$CWD/extracted_data"

# Navigate to that directory
cd $OUTPUT_DIR

# Generate the hashes for all files in the directory
find . -type f -print0 | while read -d $'\0' file
do
  # Generate the SHA-512 hash for the file
  hash=$(sha512sum "$file" | awk '{ print $1 }')

  # Append the hash and file name to the hashes.txt file
  echo "$hash  \"$file\"" >> hashes.txt
done

# Print confirmation message
echo "Hashes generated and stored in hashes.txt file."
