#!/usr/bin/env bash

l0g() {
  local b="\e[1m"
  local bn="\e[21m"
  local lc="\e[96m"
  local lcn="\e[0m"
  echo -e "$b$lc[+] $1$bn$lcn"
  sleep 2
}

aptInstl() {
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y $1 > /dev/null
  l0g "$1 Installed"
}

install_zsh() {
  ## Install zsh as shell then install oh-my-zsh
  aptInstl "zsh"
  su -l vagrant -s "/bin/sh" \
    -c "curl -fsSO https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod 755 install.sh; ./install.sh --unattended"
  chsh -s /bin/zsh vagrant
}

install_mongodb() {
  ## Install mongodb-org from mongodb repository
  curl -fsS https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - &> /dev/null
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null
  apt-get update > /dev/null
  aptInstl "mongodb-org"
  systemctl start mongod.service
  systemctl enable mongod.service &> /dev/null
}

install_miscellaneous() {
  apt-get update > /dev/null
  apt-get upgrade > /dev/null
  for i in curl git vim gnupg; do
    aptInstl "$i"
  done
}

main() {
  l0g "S T A R T I N G"
  install_miscellaneous
  install_mongodb
  install_zsh
  l0g "When first time login via \"vagrant ssh\" choose 2 if the zsh prompt show to the screen!!"
  l0g "T H E   S E R V E R  I S  R E A D Y"
}

main
