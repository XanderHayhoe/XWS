#!/bin/bash
IP_ADDR="192.168.1.1"
APP_URL="http://192.168.1.1"

echo "Configuring for $APP_URL with IP address $IP_ADDR"

sudo apt update && sudo apt upgrade -y

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# add and install dokku
wget https://packagecloud.io/dokku/dokku/gpgkey -O - | sudo apt-key add -
echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ focal main" | sudo tee /etc/apt/sources.list.d/dokku.list
sudo apt update
sudo apt install dokku -y
sudo dokku plugin:install-dependencies
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# configure LetsEncrypt (Optional - HTTPS won't work with just an IP address. you will need to create a domain)
# sudo dokku letsencrypt XWS

# config domains
sudo dokku domains:set-global $IP_ADDR

# create app
sudo dokku apps:create test-deployment

# init and push sample code
git init
git remote add dokku dokku@$IP_ADDR:test-deployment
echo "Hello, Dokku!" > index.html
git add . && git commit -m "Initial commit"

# push the App to Dokku
git push dokku master
