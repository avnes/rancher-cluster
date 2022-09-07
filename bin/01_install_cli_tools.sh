#!/bin/bash

# Make sure the script works regardless of which directory it is called from
cd "${0%/*}/.."

printf "\n\n############### Installing Linux software requirements ###############\n"
HOSTNAME_INFO=$(hostnamectl)

if [[ $HOSTNAME_INFO =~ "Fedora Linux" ]]; then
    sudo dnf install -y python curl
elif [[ $HOSTNAME_INFO =~ "CentOS Stream" ]]; then
    sudo dnf install -y python39 curl
elif [[ $HOSTNAME_INFO =~ "Ubuntu" ]]; then
   sudo apt update && sudo apt install -y python3 curl
else
    echo "Unsupported operating system"
fi

printf "\n\n############### Installing Poetry ###############\n"
curl -sSL https://install.python-poetry.org | python3 -
PATH=$HOME/.local/bin:$PATH; export PATH

printf "\n\n############### Installing Ansible ###############\n"
poetry install

printf "\n\n############### Installing Ansible roles ###############\n"
if [[ -d "ansible/roles" ]]; then
    rm -rf ansible/roles
fi
poetry run ansible-galaxy role install --roles-path ansible/roles --role-file ansible/requirements.yaml

printf "\n\n############### Installing CLI tools ###############\n"
poetry run ansible-playbook --inventory ansible/inventory/hosts.yaml ansible/install_cli_tools.yaml
