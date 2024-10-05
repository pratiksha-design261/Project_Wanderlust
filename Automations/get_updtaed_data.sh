# Backend Updated data validate
Env_file="../backend/.env.docker"
Current_url=$(sed -n "4p" $Env_file)
echo "Backend : ${Current_url}"


# Front end Updated data validate
env_file_path="../frontend/.env.docker"
current_url_1=$(cat $env_file_path)
echo "FrontEnd: ${current_url_1}"
