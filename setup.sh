#!/bin/bash

echo "Updating..."
sudo apt-get update > log.txt
echo "Upgrading..."
sudo apt-get upgrade -y >> log.txt

echo "Installing packages..."
xargs -a packages.txt sudo apt-get install -y >> log.txt

echo "Upgrading pip..."
python -m pip install --upgrade pip >> log.txt

echo "Copying files to root..."
cp .bash_aliases ~/
cp .hushlogin ~/

read -p 'Please write the name you wish to use for git: ' gituser
read -p 'Please write the email you wish to use for git: ' gitemail

git config --global user.name "$gituser" >> log.txt
git config --global user.email "$gitemail" >> log.txt

echo "Git credentials are set up"

read -p "Do you wish to install vscode? (y/n)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "\nInstalling vscode..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg >> log.txt
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' >> log.txt
    rm -f packages.microsoft.gpg >> log.txt
    sudo apt-get install code >> log.txt
else
    echo -e "\nSkipping vscode installation"
fi

read -n 1 -s -p "Adding ssh key to github, please follow the steps and press enter to continue: "
read -n 1 -s -p $'\nLogin on github, go to settings -> SSH and GPG keys. Add new ssh key: '
read -n 1 -s -p $'\nGive a title that explains what device the key belongs to: '
yes "" | ssh-keygen -o -t rsa -C "$gitemail" >> log.txt
echo -e "Generated ssh key. Please copy the following public key into github. \n"
cat ~/.ssh/id_rsa.pub
echo ""
read -n 1 -s -p "Press Add SSH key to finish: "

echo -e "\nYou are now set up" >> log.txt
