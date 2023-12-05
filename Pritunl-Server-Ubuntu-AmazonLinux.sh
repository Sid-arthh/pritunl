#!/bin/bash

# Function to detect the operating system
get_os() {
    if [ -f "/etc/redhat-release" ]; then
        echo "amazon-linux"
    elif [ -f "/etc/lsb-release" ]; then
        grep -qi "DISTRIB_ID=Ubuntu" /etc/lsb-release && echo "ubuntu"
    else
        echo "unknown"
    fi
}

# Function to install dependencies and Pritunl
install_pritunl() {
    if [ "$1" == "amazon-linux" ]; then
        # Amazon Linux setup
        sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo << EOF
        [mongodb-org-6.0]
        name=MongoDB Repository
        baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/
        gpgcheck=1
        enabled=1
        gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
        EOF

        # ... (rest of the Amazon Linux setup)

    elif [ "$1" == "ubuntu" ]; then
        # Ubuntu setup
        sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
        deb http://repo.pritunl.com/stable/apt jammy main
        EOF

        # ... (rest of the Ubuntu setup)

    else
        echo "Unsupported operating system."
        exit 1
    fi

    # Common installation steps
    sudo systemctl enable mongod pritunl
    sudo systemctl start mongod pritunl
}

# Detect the operating system
os=$(get_os)

# Install Pritunl based on the detected OS
install_pritunl "$os"
