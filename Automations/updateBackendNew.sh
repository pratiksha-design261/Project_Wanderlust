#!/bin/bash

# Set the Instance ID and path to the .env file
INSTANCE_ID="i-009e42d1cb6e8fe69"

# Retrieve the public IP address of the specified EC2 instance
ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo ${ipv4_address}

# Path to the .env file
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file
current_url=$(sed -n "4p" $file_to_find)
echo "old URL ${current_url}"

# Update the .env file if the IP address has changed
if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    echo "Front end URL is diffrent"
    if [ -f $file_to_find ]; then
        echo "Files is available"
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
    echo "Front end URL is diffrent"
fi
