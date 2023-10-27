#!/bin/bash

cd ~

echo "Getting dotfiles..."
git init
echo * > .gitignore
git remote add origin git@github.com:Wayfarer98/.dotfiles.git
git fetch
git reset --hard origin/main

# Build nerd font
fc-cache -fv

# Install neovim
echo "Installing neovim..."
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc

echo "Cloning oh-my-zsh plugins..."
git clone https://github.com/ptavares/zsh-exa.git ~/.oh-my-zsh/custom/plugins/zsh-exa
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


echo "Installing tmux..."
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure
make && sudo make install

echo "Cloning tmux package manager..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Installing fzf..."
cd ~
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz


echo "To finish configuation you need to do the following: "
echo "1. Change the font of the terminal to the Hack Nerd Font."
echo "2. Restart the computer and open tmux (write: tmux)"
echo "3. If plugins are not installed, write: <prefix> I. Prefix is either <C-a> or <C-b>"
echo "4. open nvim (nvim .). Neovim will install the plugins from the config"

