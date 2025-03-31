#!/bin/bash

date_var=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0")
LOGFILE="/tmp/${SCRIPT_NAME}-${date_var}.log"

# Define color codes for output
R="\e[31m"  # Red (Failure)
G="\e[32m"  # Green (Success)
Y="\e[33m"  # Yellow (Info)
N="\e[0m"   # Reset color

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${R}Error: Please run this script with sudo access.${N}"
    exit 1
fi

# Validation function
VALIDATE() {
    if [ $? -ne 0 ]; then
        echo -e "$2 ..... ${R}Failed${N}"
        exit 1
    else
        echo -e "$2 ...... ${G}Successful${N}"
    fi
}

# dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
# VALIDATE $? "Installing remi release"

# dnf module enable redis:remi-6.2 -y &>> $LOGFILE
# VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting redis"
