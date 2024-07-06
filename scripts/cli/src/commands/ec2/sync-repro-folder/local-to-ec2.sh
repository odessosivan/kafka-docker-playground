instance="${args[--instance]}"

if [[ $instance == *"@"* ]]
then
    instance=$(echo "$instance" | cut -d "@" -f 2)
fi
name=$(echo "${instance}" | cut -d "/" -f 1)
ip=$(echo "${instance}" | cut -d "/" -f 3)

pem_file="$root_folder/$name.pem"
username=$(whoami)

if [ ! -f "$pem_file" ]
then
    logerror "❌ aws ec2 pem file $pem_file file does not exist"
    exit 1
fi

log "👉 Sync local reproduction-models folder to ec2 instance $name"
rsync -cauv --filter=':- .gitignore' -e "ssh -i $pem_file" "$root_folder/reproduction-models" "$username@$ip:/home/$username/kafka-docker-playground"