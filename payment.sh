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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing python"

if id "roboshop" &>/dev/null; then
    echo -e "User already exists." &>> "$LOGFILE"
else
    useradd roboshop &>> "$LOGFILE"
    VALIDATE $? "User created successfully."
fi

VALIDATE $? "Adding user"

DIR="/home/centos"
if [ -d "$DIR/app" ]; then
    VALIDATE $? "app already exists." &>> "$LOGFILE"
else
    mkdir "$DIR/app" &>> "$LOGFILE"
    VALIDATE $? "app created successfully." &>> "$LOGFILE"
fi

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Curl- dowloding zip"

cd /app  &>> $LOGFILE
VALIDATE $? "Changing directory"

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing pip"

cp /root/roboshop_shellscripting/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Coping payment.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading daemon"

systemctl enable payment  &>> $LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting paymnet"