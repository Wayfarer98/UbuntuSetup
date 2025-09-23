#!/bin/bash

cd > log.txt

echo "Updating..."
sudo apt-get update
echo "Upgrading..."
sudo apt-get upgrade -y

wget "https://raw.githubusercontent.com/Wayfarer98/UbuntuSetup/master/packages.txt"
echo "Installing packages..."
sudo add-apt-repository -y ppa:dotnet/backports
sudo apt-get update
xargs -a packages.txt sudo apt-get install -y
ln -s $(which fdfind) $HOME/.local/bin/fd
rm packages.txt

echo "Upgrading pip..."
pipx install cmake

read -p 'Please write the name you wish to use for git: ' gituser
read -p 'Please write the email you wish to use for git: ' gitemail
read -p 'Write your company email: ' companyemail


echo "Adding ssh key to github"
sshkeypath="$HOME/.ssh/id_ed25519.pub"
yes "" | ssh-keygen -t ed25519 -C "$gitemail"
eval "$(ssh-agent -s)"
ssh-add ${sshkeypath}

# From https://github.com/cli/cli/blob/trunk/docs/install_linux.md
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# authenticate gh on the web
echo 'Authenticate the github CLI, press no when asked to upload ssh keys, we will do it manually'
echo 'Authenticating with both ssh_signing_key and public_key scopes'
gh auth login -h github.com -s admin:ssh_signing_key,admin:public_key

read -p 'What do you want the title of your github ssh key to be? (e.g. Laptop, Desktop, etc.): ' keytitle
gh ssh-key add "$sshkeypath" -t "$keytitle - auth" --type authentication 
gh ssh-key add "$sshkeypath" -t "$keytitle - sign" --type signing 

echo "[user]" > .gitconfig-work
echo "    user = $gituser" >> .gitconfig-work
echo "    email = $companyemail" >> .gitconfig-work
echo "    signingkey = $sshkeypath" >> .gitconfig-work
echo "[gpg]" >> .gitconfig-work
echo "    format = ssh" >> .gitconfig-work
echo "[commit]" >> .gitconfig-work
echo "    gpgsign = true" >> .gitconfig-work
echo "[tag]" >> .gitconfig-work
echo "    gpgsign = true" >> .gitconfig-work

echo "[user]" > .gitconfig
echo "    name = $gituser" >> .gitconfig
echo "    email = $gitemail" >> .gitconfig
echo "    signingkey = $sshkeypath" >> .gitconfig
echo "[gpg]" >> .gitconfig
echo "    format = ssh" >> .gitconfig
echo "[commit]" >> .gitconfig
echo "    gpgsign = true" >> .gitconfig
echo "[tag]" >> .gitconfig
echo "    gpgsign = true" >> .gitconfig
echo '[includeIf "gitdir:~/Documents/Work/"]' >> .gitconfig
echo "    path = ~/.gitconfig-work" >> .gitconfig
echo "[init]" >> .gitconfig
echo "    defaultBranch = main" >> .gitconfig

echo "Git credentials are set up"

# Install zsh
echo "Installing zsh..."
sudo apt install zsh -y 
sudo -k chsh -s "$(which zsh)" "$USER" 

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh 

echo "Getting dotfiles..."
git init
echo * > .gitignore
git remote add origin git@github.com:Wayfarer98/.dotfiles.git
git fetch
git reset --hard origin/main

read -p 'Should nerd font be installed and set as system font? (y/n): ' installfont

if [[ $installfont != "y" && $installfont != "n" ]]; then
    echo "Invalid input, defaulting to 'n'"
    installfont="n"
fi

if [[ "$installfont" == "y" ]]; then

	echo "Downloading nerd font..."
	curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep -Po '"browser_download_url": "\K.*(JetBrainsMono).*\.zip' | wget -i - >> log.txt

	echo "Installing nerd font..."
	unzip JetBrainsMono*.zip -d .fonts
	rm JetBrainsMono*.zip

	# Build nerd font
	fc-cache -fv

	echo "Changing system fonts to JetBrains Mono..."
	gsettings set org.cinnamon.desktop.interface font-name 'JetBrainsMono Nerd Font 10'
	gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'JetBrainsMono Nerd Font Bold 10'
	gsettings set org.gnome.desktop.interface document-font-name 'JetBrainsMono Nerd Font 10'
	gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10'
	gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 10'
	gsettings set org.gnome.desktop.wm.preferences titlebar-font 'JetBrainsMono Nerd Font Bold 10'
	gsettings set org.nemo.desktop font 'JetBrainsMono Nerd Font 10'

fi

# Install neovim
echo "Installing neovim..."
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd
echo "Install plugins via lazy and treesitter parsers..."
dotnet tool install -g EasyDotnet
nvim --headless +"Lazy! install" +qa
nvim --headless +"TSUpdate" +qa

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
cd
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc

echo "Cloning oh-my-zsh plugins..."
git clone https://github.com/ptavares/zsh-exa.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-exa
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


echo "Installing tmux..."
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure
make && sudo make install

echo "Cloning tmux package manager..."
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

$HOME/.tmux/plugins/tpm/bin/install_plugins

echo "Installing fzf..."
cd
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install

echo "Installing lazygit..."
curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"browser_download_url": "\K.*(linux_x86_64).*\.tar.gz"' | wget -i - -O lazygit.tar.gz
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit

echo "Installing nvm and node..."
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash'
nvm install node

echo "Installing Ghostty..."
curl -fsSL https://download.opensuse.org/repositories/home:clayrisser:sid/Debian_Unstable/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/home_clayrisser_sid.gpg > /dev/null
ARCH="$(dpkg --print-architecture)"
sudo tee /etc/apt/sources.list.d/home:clayrisser:sid.sources > /dev/null <<EOF
Types: deb
URIs: http://download.opensuse.org/repositories/home:/clayrisser:/sid/Debian_Unstable/
Suites: /
Architectures: $ARCH
Signed-By: /etc/apt/keyrings/home_clayrisser_sid.gpg
EOF
sudo apt update
sudo apt install ghostty

