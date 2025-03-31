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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling"

dnf module enable nodejs:18 -y  &>> $LOGFILE
VALIDATE $? "Enabling"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing"

id roboshop
if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "robo user creation"
else
   echo "user exits"
fi

VALIDATE $? "creating user"

mkdir -p /app &>> $LOGFILE  # -p if the app folder is available it will ignore if not create 
VALIDATE $? "Creatig app dir"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart.zip"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE  # o is to overwrite
VALIDATE $? "Unzip"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm depncdies" 

cp /root/roboshop_shellscripting/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "cp"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon loading"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "cenabling"

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting"