#!/bin/bash

# Set instnace ID on which Argo CD is setup
INSTANCE_ID="i-009e42d1cb6e8fe69"

#Retrive public IP from the EC2 Instance 
IPV4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "${IPV4_address}"
#aws ec2 describe-instances --instance-ids $INSTANCE_ID:This AWS CLI command queries information about an EC2 instance based on the instance ID stored in the variable $INSTANCE_ID.
#--query 'Reservations[0].Instances[0].PublicIpAddress': The --query option is used to filter the specific information from the returned JSON structure.
# Reservations[0] refers to the first reservation object in the response.
# Instances[0] refers to the first instance in that reservation.
# PublicIpAddress retrieves the public IPv4 address of that EC2 instance.
# --output text: This formats the output as plain text instead of JSON, making it easier to capture and assign to a variable.

#Path to env file
Env_file="../backend/.env.docker"

# Updated URL
Updated_BE_Url="BACKEND_URL=\"http://${IPV4_address}:5173\""
echo "${Updated_BE_Url}"

#Store already present (old) frontend url in variable
Current_url=$(sed -n "4p" $Env_file)
echo "CU URL= ${Current_url}"

#Check if both URL re same if not update new url to .env.docker file
if [[ "${Current_url}" != "BACKEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    echo "Ips are not equal"
    if [ -f $Env_file ]; then                                                 # Checks if file is availabel on location
        echo "File available"
        sed -i -e "s|BACKEND_URL.*|BACKEND_URL=\"http://${IPV4_address}:5173\"|g" $Env_file
        echo "File updated updated IP is ${Current_url}"
    else
        echo "Error: File Not Found."
    fi
fi


# sed -i -e:

# sed: Stream editor used to perform basic text transformations on an input stream (a file in this case).
# -i: This flag tells sed to modify the file "in-place," meaning the changes are directly applied to the file ($Env_file).
# -e: Allows specifying a script for the sed command.
# s|FRONTEND_URL.*|${Updated_FE_Url}|g:

# s|...|...|g: This is the sed substitution command. The s stands for substitute, and the g at the end ensures it performs a global replacement on each line.
# FRONTEND_URL.*: This is a regular expression that matches FRONTEND_URL followed by anything (.* matches any sequence of characters).
# ${Updated_FE_Url}: This is the replacement value, which is the content of the Updated_FE_Url variable. It contains the new FRONTEND_URL="http://<IPv4_Address>:5173" string.
