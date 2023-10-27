#!/bin/bash

cd ~ > log.txt

echo "Updating..."
sudo apt-get update
echo "Upgrading..."
sudo apt-get upgrade -y

wget "https://raw.githubusercontent.com/Wayfarer98/UbuntuSetup/master/packages.txt" >> log.txt
echo "Installing packages..."
xargs -a packages.txt sudo apt-get install -y
rm packages.txt

echo "Upgrading pip..."
python -m pip install --upgrade pip
python -m pip install cmake

read -p 'Please write the name you wish to use for git: ' gituser
read -p 'Please write the email you wish to use for git: ' gitemail
read -p 'Do you want to configure a company git config? (y/n)' -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p 'Write your company email: ' companyemail
    echo "[user]" > .gitconfig-work
    echo "\tuser = $gituser" >> .gitconfig-work
    echo "\temail = $companyemail" >> .gitconfig-work
    echo "\t#signingkey = add key here" >> .gitconfig-work
fi

echo "[user]" > .gitconfig
echo "\tname = $gituser" >> .gitconfig
echo "\temail = $gitemail" >> .gitconfig
echo "# Uncomment below when signingkey has been added" >> .gitconfig
echo "\t#signing = add key here" >> .gitconfig
echo "#[commit]" >> .gitconfig
echo "\t#gpgsign = true" >> .gitconfig
echo '[includeIf "gitdir:~/Documents/Work/"]' >> .gitconfig
echo "\tpath = ~/.gitconfig-work" >> .gitconfig
echo "[init]" >> .gitconfig
echo "\tdefaultBranch = main" >> .gitconfig

echo "Git credentials are set up"

echo "Adding ssh key to github"
yes "" | ssh-keygen -t ed25519 -C "$gitemail"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# From https://github.com/cli/cli/blob/trunk/docs/install_linux.md
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# authenticate gh on the web
echo 'Authenticate the github CLI'
gh auth login -h github.com -s admin:public_key

# Install zsh
echo "Installing zsh..."
sudo apt install zsh -y
sudo -k chsh -s "$(which zsh)" "$USER"

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

echo -e "\nYour initial setup is complete\n"
echo "Please open and close your terminal" 
