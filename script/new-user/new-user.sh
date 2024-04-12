#!/bin/bash

printf "Quel est l'adresse IP de votre serveur POSTGRES ?\n"
read IP_PSQL

printf "Quel est l'adresse IP de votre serveur ODOO ?\n"
read IP_ODOO

printf "Quel est le nom d'utilisateur que vous souhaitez ?\n"
read USER_NAME

printf "Quel est le port que vous souhaitez utilisé ?\n"
read PORT

mkdir user-$USER_NAME
cp -r config user-$USER_NAME
cp docker-compose.yml user-$USER_NAME

printf "create USER $USER_NAME WITH PASSWORD '$USER_NAME';\nCREATE DATABASE odoo_$USER_NAME WITH OWNER=$USER_NAME;\nGRANT ALL PRIVILEGES ON DATABASE odoo_$USER_NAME TO $USER_NAME;\n" > user-$USER_NAME/new-$USER_NAME.sql

sed -i -e "s/NAME/$USER_NAME/g" -e "s/PORT/$PORT/g" user-$USER_NAME/docker-compose.yml
sed -i -e "s/NAME/$USER_NAME/g" -e "s/IP_PSQL/$IP_PSQL/g" user-$USER_NAME/config/odoo.conf

scp user-$USER_NAME/new-$USER_NAME.sql user@$IP_PSQL:/tmp

ssh user@$IP_ODOO "mkdir user-$USER_NAME"
scp user-$USER_NAME/docker-compose.yml user@$IP_ODOO:~/user-$USER_NAME
scp -r user-$USER_NAME/config user@$IP_ODOO:~/user-$USER_NAME

scp create-user.sh user@$IP_PSQL:~
ssh user@$IP_PSQL "chmod u+x create-user.sh"
ssh user@$IP_PSQL "./create-user.sh $USER_NAME"

scp start-odoo.sh user@$IP_ODOO:user-$USER_NAME
ssh user@$IP_ODOO "chmod u+x user-$USER_NAME/start-odoo.sh"
ssh user@$IP_ODOO "./user-$USER_NAME/start-odoo.sh $USER_NAME"