#!/bin/bash
# ohlittlebrain@gmail.com
# Log Fail Check
# Stephen, Daniel, Carlton, Jeffe
# Define file paths of log file and bin, sbin and any other functions we will be running.


LOG_FILE=/var/log/auth.log
HOUR_LOG=/var/log/hour.log
THRESHOLD=5
TEXT_ADDR="alias of us 3"
bin=/usr/bin
sbin=/usr/sbin
egrep=/usr/bin/egrep

# Check if auth.log file exists
if test -f "$log"; then
echo "Scanning auth.log for Failed login attmepts."
else
# If log file does not exist, send message
echo "Could not locate log file."
fi
# read auth.log file by last hour
while read -r rec 
     # "date" to convert logged times into seconds
do   age=$(($(date +%s)-$(date -d "${rec:0:16}" +%s)))
     #  All logs in the past hour are written to file.log
     [ $age -ge 0 -a $age -le 3600 ] && echo "$rec" > "$HOUR_LOG"
done < "$LOG_FILE"
# Scan temp file for Failed|Failure
mapfile -t result <<< $($bin/awk -v awkvar=$HOSTNAME 'BEGIN { FS=awkvar; OFS="|" } /ailed|ailure/ {print $1,$2}' $HOUR_LOG);

count=0;

for i in "${result[@]}"
do
    IFS="|" read entry_time message <<< $i;
    et=$($bin/date -d "$entry_time" +"%s");
    if [[ $et -ge $hour ]]
    then
        ((count++));
        echo "$entry_time | $message">>$HOUR_LOG;
    fi
done
# print out how many failures total.
echo "$count failures detected";
# If more than 5 failed attempts, send text.
if [ $count -gt 5 ]
then
echo "More than 5 failed attempts";
echo "You've had $count Failed SSH attempts in the past hour!" | sendmail -v 7204221840@text.att.net

cp $HOUR_LOG $HOUR_LOG$hour;
else
echo "Less than 5 failed attempts"
echo "You've had $count Failed SSH attempts in the past hour!" | sendmail -v 7204221840@text.att.net

fi
