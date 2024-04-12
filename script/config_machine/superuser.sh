#!/bin/bash

apt update && apt full-upgrade -y
apt install sudo -y
sleep 5
/sbin/usermod -aG sudo user