curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="/home/workspace/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# add nvm.sh to /etc/bash.bashrc
echo "export NVM_DIR=\"/home/workspace/.nvm\"" | sudo tee -a /etc/bash.bashrc
echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" | sudo tee -a /etc/bash.bashrc

# source
source /etc/bash.bashrc
