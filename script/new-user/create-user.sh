#!/bin/bash

sudo -S -i -u  postgres psql -c "\i /tmp/new-$1.sql"

sudo -S -i -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=$1 user-$1

sudo -S systemctl restart postgresql