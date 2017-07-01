#!/usr/bin/env bash
echo "Installing LXD and setting it up..."
sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable -y
apt-get update >/dev/null 2>&1
apt-get dist-upgrade -y >/dev/null 2>&1
apt-get install -y lxd lxc >/dev/null 2>&1
adduser ubuntu lxd
lxc list
lxc config set core.https_address "[::]:8443"
