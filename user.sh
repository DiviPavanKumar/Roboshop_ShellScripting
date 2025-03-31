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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading catloguge.zip"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE  # o is to overwrite
VALIDATE $? "Unzip"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm depncdies" 

cp /root/roboshop_shellscripting/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Cp user.service to etc................"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Installing daemon"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"

cp /root/roboshop_shellscripting/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installng shl"

mongo --host mongodb.pavandivi.online </app/schema/user.js &>> $LOGFILE
VALIDATE $? "mongodbre cnctd"
