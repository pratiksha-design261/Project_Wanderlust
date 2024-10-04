#Get instance Id
InstanceID="i-08207742f70c49793"

#Get IP address from Instnace ID for frontend with instance id of EC2
IPV4_ID_FE=$(aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# File where we need to update IPV4 address
env_file_path="../frontend/.env.docker"

# Upadted Front end url
Updated_FE_Url="VITE_API_PATH=\"http://${IPV4_ID_FE}:31100\""

# get current url from file
current_url=$(cat $env_file_path)

# compare current url and updated url, if its diffrent update in env.docker file
if [[ ${current_url} != ${Updated_FE_Url} ]]; then
    if [ -f $env_file_path ]; then
        sed -i -e "s|VITE_API_PATH.*|${Updated_FE_Url}|g" $env_file_path
    else
        echo "Error: File not found"
    fi
fi
