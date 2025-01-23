#!/bin/bash
DOMAIN="example.com" 
APP_NAME="test-deployment"

echo "Configuring Dokku with domain $DOMAIN"

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

# set domain
sudo dokku domains:set-global $DOMAIN

# configure LetsEncrypt for HTTPS (NOT optional)
sudo dokku letsencrypt:enable

# create app
sudo dokku apps:create $APP_NAME
sudo dokku domains:add $APP_NAME $DOMAIN

# init and push sample code
git init
git remote add dokku dokku@$IP_ADDR:test-deployment
echo "Hello, Dokku!" > index.html
git add . && git commit -m "Initial commit"

# push to Dokku
git push dokku master

# enable LetsEncrypt for the app
sudo dokku letsencrypt $APP_NAME

echo "Setup complete. Your app should now be accessible at https://$DOMAIN"
