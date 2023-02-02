#!/bin/bash

echo "Updating..."
sudo apt-get update > /dev/null
echo "Upgrading..."
sudo apt-get upgrade -y > /dev/null

echo "Installing packages..."
xargs -a packages.txt sudo apt-get install -y > /dev/null

echo "Upgrading pip..."
python -m pip install --upgrade pip > /dev/null

echo "Copying files to root..."
cp .bash_aliases ~/
cp .hushlogin ~/

read -p 'Please write the name you wish to use for git: ' gituser
read -p 'Please write the email you wish to use for git: ' gitemail

git config --global user.name "$gituser"
git config --global user.email "$gitemail"

echo "Git credentials are set up"

read -p "Do you wish to install vscode? (y/n)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]] then
    echo "Installing vscode"
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - > /dev/null
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /dev/null
    sudo apt install code -y > /dev/null
else
    echo "Skipping vscode installation"

read -n 1 -s -p "Adding ssh key to github, please follow the steps and press enter to continue: "
read -n 1 -s -p "Login on github, go to settings -> SSH and GPG keys. Add new ssh key: "
read -n 1 -s -p "Give a title that explains what device the key belongs to: "
yes "" | ssh-keygen -o -t rsa -C "$gitemail" > /dev/null
echo -e "Generated ssh key. Please copy the following public key into github. \n"
cat ~/.ssh/id_rsa.pub
echo ""
read -n 1 -s -p "Press Add SSH key to finish: "

echo "You are now set up"
