#!/bin/bash

printf "Pour une bonne installation, nous vous demandons l'adresse IP que vous allez ou que vous avez attibué pour la machine 'odoo'.\nEntré l'adresse juste ici:"
read IP_ODOO

sudo -S apt install postgresql -y
sudo -S apt install rsync -y

sudo -S mkdir -p /var/lib/postgresql/backups
systemctl enable postgresql
systemctl start postgresql

sudo -S -i -u postgres psql -c "create user admin with password 'admin' superuser"
sudo -S -i -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=admin admin

sudo -S sed -i -e "/host    all             all             127.0.0.1\/32            scram-sha-256/a host\tall\t\tall\t\t$IP_ODOO\/32\t\ttrust" /etc/postgresql/15/main/pg_hba.conf

sudo -S sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/15/main/postgresql.conf

sudo -S -i -u postgres psql -c "alter user admin with createdb createrole;"

sudo -S systemctl restart postgresql