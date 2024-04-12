#!/bin/bash

printf"Quelle est l'adresse ip de votre serveur postgres ?\n"
read psql

rsync -e ssh -avz backups/save.sql user@$psql:/home/user/

ssh user@$psql "sudo -S mv /home/user/save.sql /var/lib/postgresql/backups"

ssh user@$psql "sudo -S su - postgres -c 'psql -f backups/save.sql'"


