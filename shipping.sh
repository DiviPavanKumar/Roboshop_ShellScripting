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

dnf install maven -y  &>> $LOGFILE
VALIDATE $? "Installing maven"

if id "roboshop" &>/dev/null; then
    echo -e "User already exists." &>> "$LOGFILE"
else
    useradd roboshop &>> "$LOGFILE"
    VALIDATE $? "User created successfully."
fi

DIR="/home/centos"
if [ -d "$DIR/app" ]; then
    VALIDATE $? "app already exists." &>> "$LOGFILE"
else
    mkdir "$DIR/app" &>> "$LOGFILE"
    VALIDATE $? "app created successfully." &>> "$LOGFILE"
fi

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Curl command"

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzip"

mvn clean package  &>> $LOGFILE
VALIDATE $? "Clean package"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE
VALIDATE $? "Renaming the shipping file"

cp /root/roboshop_shellscripting/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copping shipping.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading daemon"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

yum install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.pavandivi.online -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE

mysql -h mysql.pavandivi.online -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE

mysql -h mysql.pavandivi.online -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping"