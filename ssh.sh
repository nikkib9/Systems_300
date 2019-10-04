#!/usr/bin/bash
# 
# Most functions done by Nikki Benoit
# Worked on with Stephen Jones, Jeffery Crones
#
####################################
# Check log for ssh failures and text failures
# every hour.  Do not text previous failures.
####################################
#
# Define Locations and Defaults
#
BIN="/bin"
USRBIN="/usr/bin"
USRSBIN='/usr/sbin'
# Auth.log File Location
log="/var/log/auth.log"
# Defaults - to be changed by user
default_fail_log="/var/log/sshfail.log"
default_time="1hour"
default_fail_threshold="5"
email2text_address=""
#
# main program calling each function in order
#
main() {
    check_log
    set_defaults
    scan_file
}
#######################################
#          FUNCTIONS
#######################################
# Check if log file exists - exit with error if not
check_log(){
 if [ ! -f "$log" ]; then
   status=$?
   echo "$log" does not exist
   exit $status
 fi
}
#
set_defaults(){
    read -p "Location to save audit log (Default $default_fail_log): " fail_log
    fail_log=${fail_log:-${default_fail_log}}
    echo "Fail log location: " $fail_log
    read -p "Timeframe to scan $log (Default $default_time): " time_frame
    time_frame=${time_frame:-${default_time}}
    echo "Timeframe: " $time_frame
    read -p "Enter threshold for ssh failure attempts (Default $default_fail_threshold): " fail_threshold
    fail_threshold=${fail_threshold:-${default_fail_threshold}}
    echo "Fail threshold: " $fail_threshold
    read -p "Enter the email to text address (Format ex: 5551234567@txt.att.net): " email2text_address
    echo "Email to Text: " $email2text_address
}
#
scan_file(){
    $BIN/egrep "^$(date -d -$time_frame +'%b %d %H')" $log | $BIN/egrep "sshd" | $BIN/egrep "Fail*" > $fail_log
    current_fail_count=$($USRBIN/wc -l $fail_log | $USRBIN/awk '{print $1}')
                    #TESTING PURPOSES
        # echo ${current_fail_count}
    if [ ${current_fail_count} -ge ${fail_threshold} ]; then
        send_mail
        exit $?
    fi
}
#
send_mail(){
 $USRBIN/echo "You've had $current_fail_count or more Failed SSH attempts in the past $time_frame!" | $USRSBIN/sendmail -v ${email2text_address}
                #TESTING PURPOSES
      # echo "$($BIN/cat $fail_log)"
}
#######################################
#              RUN MAIN
#######################################
main "$@"; exit $?












#######################################
#             AUTOMATION
#######################################
#ssmtp_conf="/etc/ssmtp/ssmtp.conf"
# check_cmds
# config_permissions
# configure_ssmtp
# import ssmtp
# Check if essential commands exist and install if not
# check_cmds(){
#   command -v ssmtp >/dev/null 2>&1 || { sudo apt install ssmtp -y; }
# }
# Check and edit permissions for ssmtp.conf file
#config_permissions(){
#   chmod +x $ssmtp_conf
#   chown 640 $ssmtp_conf
#   if [ ! +rx $ssmtp_conf ]
#      then { sudo chmod 755 $ssmtp_conf; }
#   fi
#}
# configure_ssmtp(){
#   echo "Setting up SSMTP.CONF"
#   read -p "Provide originating email account: " email
#   read -ps "Provide email password: " pass
#
#   sudo echo "FromLineOverride=YES
# AuthUser=$email
# AuthPass=$pass
# mailhub=smtp.gmail.com:587
# UseSTARTTLS=YES" >> $ssmtp_conf
# }
