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

dnf module disable mysql -y  &>> $LOGFILE
VALIDATE $? "Disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo  &>> $LOGFILE
VALIDATE $? "Copying the repo"

dnf install mysql-community-server -y  &>> $LOGFILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld  &>> $LOGFILE
VALIDATE $? "Enabling mysqld"

systemctl start mysqld  &>> $LOGFILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1  &>> $LOGFILE
VALIDATE $? "Mysql password"