#!/bin/sh

cd ~

echo "Getting dotfiles..."
git init
echo * > .gitignore
git remote add origin git@github.com:Wayfarer98/.dotfiles.git
git fetch
git checkout origin/main -b main

# Build nerd font
fc-cache -fv

# Install neovim
echo "Installing neovim..."
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc

echo "Installing tmux..."
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure
make && sudo make install

echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "Installing oh-my-zsh plugins..."
git clone https://github.com/ptavares/zsh-exa.git ~/.oh-my-zsh/custom/plugins/zsh-exa
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "To finish configuation you need to do the following: "
echo "1. Restart the terminal and open tmux (write: tmux)"
echo "2. If plugins are not installed, write: <prefix> I. Prefix is either <C-a> or <C-b>"
echo "3. open nvim (nvim .). Neovim will install the plugins from the config"

