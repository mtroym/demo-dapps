curl -L https://foundry.paradigm.xyz | bash


source ~/.bashrc

foundryup

mkdir -p ~/bin

# download and extract just to ~/bin/just
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# add `~/bin` to the paths that your shell searches for executables
# this line should be added to your shells initialization file,
# e.g. `~/.bashrc` or `~/.zshrc`
export PATH="$PATH:$HOME/bin"
echo 'export PATH="$PATH:$HOME/bin' >> ~/.bashrc
# just should now be executable
just --help