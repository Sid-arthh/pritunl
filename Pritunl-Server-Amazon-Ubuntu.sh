#!/bin/sh
os_type=""
# Function to detect the operating system
get_os() {
    if [ -f "/etc/os-release" ]; then
        os_type=$(awk -F= '/^NAME/{gsub("\"", "", $2); print $2}' /etc/os-release)
        echo "$os_type"
        if [ "$os_type" = "Amazon Linux" ]; then
            echo "amazon-linux"
        elif [ "$os_type" = "Ubuntu" ]; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to install dependencies and Pritunl
install_pritunl() {
    if [ "$1" = "amazon-linux" ]; then
        # Amazon Linux setup
        sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo << 'EOF'
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        # Additional Amazon Linux setup
        sudo yum -y install oracle-epel-release-el8
        sudo yum-config-manager --enable ol8_developer_EPEL
        sudo yum -y update

        # WireGuard server support
        sudo yum -y install wireguard-tools

        sudo yum -y remove iptables-services
        sudo systemctl stop firewalld.service
        sudo systemctl disable firewalld.service

        # Import signing key from keyserver
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp; sudo rpm --import key.tmp; rm -f key.tmp
        # Alternative import from download if keyserver offline
        sudo rpm --import https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc

        # Install updated openvpn package from pritunl
        sudo yum --allowerasing install pritunl-openvpn

        sudo yum -y install pritunl mongodb-org
        sudo systemctl enable mongod pritunl
        sudo systemctl start mongod pritunl

    elif [ "$1" = "ubuntu" ]; then
        # Ubuntu setup
        sudo tee /etc/apt/sources.list.d/pritunl.list << 'EOF'
deb http://repo.pritunl.com/stable/apt jammy main
EOF

        # Additional Ubuntu setup
        # Import signing key from keyserver
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        # Alternative import from download if keyserver offline
        curl https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo apt-key add -

        sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list << 'EOF'
deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse
EOF

        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

        sudo apt update
        sudo apt --assume-yes upgrade

        # WireGuard server support
        sudo apt -y install wireguard wireguard-tools

        sudo ufw disable

        sudo apt -y install pritunl mongodb-org
        sudo systemctl enable mongod pritunl
        sudo systemctl start mongod pritunl

    else
        echo "Unsupported operating system."
        exit 1
    fi
}

# Detect the operating system
os=$(get_os)

# Install Pritunl based on the detected OS
install_pritunl "$os"
