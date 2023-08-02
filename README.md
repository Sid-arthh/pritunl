# pritunl
## Installation Steps

    sudo apt-get update -y
    sudo apt-get upgrade -y
    echo "deb http://repo.pritunl.com/stable/apt focal main" | sudo tee /etc/apt/sources.list.d/pritunl.list
    echo "deb [arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    sudo curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    sudo apt install libffi7
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7AE645C0CF8E292A
    sudo apt update
    sudo apt install pritunl -y
    sudo apt install mongodb-org -y
    sudo systemctl start pritunl mongod
    sudo systemctl enable pritunl mongod
    sudo systemctl status pritunl

Access the UI on your IP 

TO generate setup-key and credential

    sudo pritunl setup-key
    sudo pritunl default-password
