#Get instance Id
INSTANCE_ID="i-009e42d1cb6e8fe69"

#Get IP address from Instnace ID for frontend with instance id of EC2
IPV4_ID_FE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "${IPV4_ID_FE}"
# File where we need to update IPV4 address
env_file_path="../frontend/.env.docker"

# Upadted Front end url
Updated_FE_Url="VITE_API_PATH=\"http://${IPV4_ID_FE}:31100\""
echo "New URL: ${Updated_FE_Url}"

# get current url from file
current_url=$(cat $env_file_path)
echo "old URL: ${current_url}"

# compare current url and updated url, if its diffrent update in env.docker file
if [[ ${current_url} != ${Updated_FE_Url} ]]; then
     echo "url is not equal"
    if [ -f $env_file_path ]; then
        echo "File is available"
        sed -i -e "s|VITE_API_PATH.*|${Updated_FE_Url}|g" $env_file_path
        echo "URL Updated"
    else
        echo "Error: File not found"
    fi
fi
