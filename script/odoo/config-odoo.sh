#!/bin/bash

printf "Quelle est l'adresse de la machine où se trouve postgres ?"
read IP_PSQL

printf "[options]\n\naddons_path = /mnt/extra-addons\ndata_dir = /var/lib/odoo\nlogfile = /var/log/odoo/odoo-server.log\n\nadmin_passwd = admin\ndb_host = $IP_PSQL\ndb_port = 5432\ndb_user = admin\ndb_password = admin\ndb_maxconn = 64\ndb_name = admin\nwithout_demo = true" > odoo/config/odoo.conf