#!/bin/bash

sudo -S apt-get install -y docker docker-compose
sleep 2
sudo -S docker network create web-odoo
sleep 2
cd odoo
sudo -S docker-compose up -d
