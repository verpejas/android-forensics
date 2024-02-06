#!/bin/bash
# Command set -e will break the execution if something exits with anything other than status 0 or there is an error during execution
set -e
clear
echo "
##############################################################################################################
# This script extracts data from already extracted databases, stored in the extracted_data folder            #
##############################################################################################################
"

# Set or create required variables and directories
CWD=$(pwd)
mkdir -p $CWD/extracted_data/extracted_db
extr=$CWD/extracted_data/extracted_db
CHROME_DATA_PATH="$CWD/extracted_data/chrome/app_chrome/Default"

# Extract SMS/MMS messages and group them by conversations/phone numbers
#$1 - date, $2 - phone number, $3 - message body, $4 - type (2 - sent/1 - received)
messages=$(sqlite3 -separator ' | ' $CWD/extracted_data/telephony_mms_sms/mmssms.db "SELECT datetime(date/1000, 'unixepoch', \
                         'localtime') as date, address, body, type FROM sms ORDER BY address, date;" | awk -F' [|] ' '
BEGIN {
    OFS=" | "
    prev_number = ""
}
{
    curr_number = $2
    if (prev_number == "") {
        # First message, print the number and message
        print "Conversation with " curr_number, ""
        if ($4 == 2) {
            print $1, "sent:", $3
        } else {
            print $1, "received:", $3
        }
    } else if (curr_number == prev_number) {
        # Same conversation, print the message
        if ($4 == 2) {
            print $1, "sent:", $3
        } else {
            print $1, "received:", $3
        }
    } else {
        # New conversation, print the number and message
        print "", ""
        print "Conversation with " curr_number, ""
        if ($4 == 2) {
            print $1, "sent:", $3
        } else {
            print $1, "received:", $3
        }
    }
    prev_number = curr_number
}')

echo -e "SMS/MMS messages extracted into extracted_messages.txt file\n"
echo "$messages" > $extr/messages.txt

# Extract contacts to a text file
# mimetype_id=5 for phone numbers
contacts=$(sqlite3 -separator ' | ' $CWD/extracted_data/contacts/contacts2.db "SELECT display_name, data1 FROM raw_contacts \
                      JOIN data ON raw_contacts._id = data.raw_contact_id \
                      WHERE mimetype_id = 5;") 
echo -e "Contacts extracted into contacts.txt file\n"
echo "$contacts" > $extr/contacts.txt

# Extract calendar events to a text file
events=$(sqlite3 -separator ' | ' "$CWD/extracted_data/calendar/calendar.db" "SELECT title, description, datetime(dtstart/1000, \
                     'unixepoch', 'localtime'), datetime(dtend/1000, 'unixepoch', 'localtime') FROM events;")
echo "$events" > "$extr/calendar.txt"
echo -e "Calendar events extracted to calendar.txt\n"


# Extract call logs to a text file
sqlite3 "$CWD/extracted_data/callog/databases/logs.db" "SELECT strftime('%Y-%m-%d %H:%M:%S', date/1000, 'unixepoch', 'localtime'), \
                    duration, number, name, type FROM logs WHERE duration <> 0 ORDER BY date DESC;" \
| awk -F '|' '{print "Date: "$1"\nDuration: "$2"\nNumber: "$3"\nName: "$4"\nType: "$5"\n\n"}' > "$extr/call_logs.txt"
echo -e "Call logs data extracted into call_logs.txt file\n"


# Extract login data to a text file
sqlite3 "$CHROME_DATA_PATH/Login Data" "SELECT origin_url, username_value, password_value FROM logins" \
| while IFS='|' read -r url username password; do
    echo "URL: $url" >> "$extr/login_data.txt"
    echo "Username: $username" >> "$extr/login_data.txt"
    echo "Password: $password" >> "$extr/login_data.txt"
    echo "" >> "$extr/login_data.txt"
done
echo -e "Login data extracted into login_data.txt file\n"

# Extract cookies data to a text file
sqlite3 "$CHROME_DATA_PATH/Cookies" "SELECT host_key, name, value, encrypted_value, creation_utc, expires_utc FROM cookies" \
| while IFS='|' read -r host name value encrypted_value; do
    echo "Host: $host" >> "$extr/cookies_data.txt"
    echo "Name: $name" >> "$extr/cookies_data.txt"
    echo "Value: $value" >> "$extr/cookies_data.txt"
    echo "Encrypted Value: $encrypted_value" >> "$extr/cookies_data.txt"
    echo "" >> "$extr/cookies_data.txt"
done
echo -e "Cookies data extracted into cookies_data.txt file\n"

# Extract browsing history to a text file
sqlite3 -json "$CHROME_DATA_PATH/History" "SELECT title, url, last_visit_time FROM urls" \
| jq -r '.[] | {Title: .title, URL: .url, "Last Visit Time": (.last_visit_time/1000000 - 11644473600 | strftime("%Y-%m-%d %H:%M:%S"))}' \
| while read -r line; do
  echo "$line"
  echo ""
done >> "$extr/browsing_history.txt"
echo -e "Browsing history extracted into browsing_history.txt file\n"

# For the browser part, setting sqlite3 to json and processing using jq was needed, as the query would hang when the "|" character was in the title,
# for example the Gmail page title that has the pipe character, was stopping the execution and hanging the query.

echo -e "\nData extraction from databases complete!\nThe script has created" `find $extr/ -type f | wc -l` "file(s) in $extr.\n"
