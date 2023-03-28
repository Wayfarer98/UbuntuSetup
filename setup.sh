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
    sudo apt-get update >> log.txt
    sudo apt-get install code >> log.txt
else
    echo -e "\nSkipping vscode installation"
fi

read -n 1 -s -p "Adding ssh key to github"
yes "" | ssh-keygen -t ed25519 -C "$gitemail" >> log.txt
eval "$(ssh-agent -s)" >> log.txt

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y >> log.txt

echo -e "\nYou are now set up\n" >> log.txt
