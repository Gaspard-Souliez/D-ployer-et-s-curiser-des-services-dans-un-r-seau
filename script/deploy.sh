#!/bin/bash

# Récupère le nom et l'adresse ip de la machine
printf "\n\nQuel nom souhaitez vous donner à votre machine virtuelle. \nUne fois le nom entré, tapez sur la touche 'entrer' pour confirmer.\n"
read MACHINE_NAME
echo Vous avez decider de nommer votre machine avec le nom suivant: $MACHINE_NAME

printf "\n\nQuelle adresse souhaitez vous attribuer à votre machine virtuelle. \nUne fois le nom entré, tapez sur la touche 'entrer' pour confirmer.\n"
read STATIC_IP
echo L\'adresse IP de la machine sera: $STATIC_IP

#Creation de la machine virtuelle et démarrage
vmiut creer $MACHINE_NAME && vmiut start $MACHINE_NAME

# On boucle tant que l'ip n'est pas attribuée
while [[ -z "$(vmiut info $MACHINE_NAME | grep 'ip-possible=' | cut -d '=' -f 2)" ]];
do
    sleep 1
done

# On stocke l'ip automatique de la machine
IP_AUTOMATIQUE=$(vmiut info $MACHINE_NAME | grep 'ip-possible=' | cut -d '=' -f 2)
echo L\'adresse ip de la machine est: $IP_AUTOMATIQUE

#Genereation de la cle ssh
ssh-keygen -f ~/.ssh/known_hosts -R "$IP_AUTOMATIQUE"
printf "\n\nPour implémenter votre clé publique dans $MACHINE_NAME, veuillez saisir le mot de passe suivant :\nuser\n\n"
ssh-copy-id user@$IP_AUTOMATIQUE

# Permet de mettre la bonne adresse ip pour le fichiers interfaces
printf "source /etc/network/interfaces.d/*\n\nauto lo\niface lo inet loopback\n\nallow-hotplug enp0s3\niface enp0s3 inet static\n  address $STATIC_IP/16\n  gateway 10.42.0.1\n" > config_machine/interfaces
printf "127.0.0.1       localhost\n127.0.1.1       $MACHINE_NAME\n\n::1     localhost ip6-localhost ip6-loopback\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n" > config_machine/hosts
printf $MACHINE_NAME > config_machine/hostname

printf "\n\nSi vous êtes invité à fournir le mot de passe de l'utilisateur, veuillez entrer :user\n\n"

scp config_machine/interfaces user@$IP_AUTOMATIQUE:~
scp config_machine/hosts user@$IP_AUTOMATIQUE:~
scp config_machine/hostname user@$IP_AUTOMATIQUE:~
scp config_machine/move.sh user@$IP_AUTOMATIQUE:~

ssh user@$IP_AUTOMATIQUE "chmod u+x move.sh"
printf "\nVeuillez entrer le mot de passe suivant pour changer l'IP et le hostname : root\n\n"
ssh user@$IP_AUTOMATIQUE "su -c ./move.sh"

# On redemare la machine
sleep 5
vmiut stop $MACHINE_NAME

sleep 10
vmiut start $MACHINE_NAME

ssh-keygen -f ~/.ssh/known_hosts -R "$STATIC_IP"

fail 2> /dev/null

while [[ $? -gt 0 ]];
do
    sleep 1
    ssh-copy-id user@$STATIC_IP
done

sleep 5
scp config_machine/superuser.sh user@$STATIC_IP:~
ssh user@$STATIC_IP "chmod u+x superuser.sh"

sleep 2
printf "\nVeuillez entrer le mot de passe suivant pour changer l'IP et le hostname : root\n\n"
ssh user@$STATIC_IP "su -c /home/user/superuser.sh"

sleep 5
vmiut stop $MACHINE_NAME && vmiut start $MACHINE_NAME

if [ "$MACHINE_NAME" = 'psql-test' ]
then
    echo "Le script a identifié psql, donc il procédera à l'installation de ce dernier."
    
    scp postgres/psql.sh user@$STATIC_IP:~
    scp postgres/save.sh user@$STATIC_IP:~
    sleep 3
    ssh user@$STATIC_IP "chmod u+x psql.sh"
    ssh user@$STATIC_IP ./psql.sh
elif [ "$MACHINE_NAME" = 'save-test' ]
then
    echo "Le script a identifié save, donc il procédera à l'installation de ce dernier."
    
    scp postgres/restore.sh user@$STATIC_IP:~
    sleep 3
    ssh user@$STATIC_IP "chmod u+x restore.sh"
    ssh user@$STATIC_IP "sudo -S apt install rsync -y"
elif [ "$MACHINE_NAME" = 'odoo-test' ]
then
    echo "Le script a identifié Odoo, donc il procédera à l'installation de ce dernier."
    ./odoo/config-odoo.sh
    
    scp -r odoo user@$STATIC_IP:~
    scp -r traefik user@$STATIC_IP:~
    
    sleep 3
    ssh user@$STATIC_IP "chmod u+x odoo/odoo.sh"
    ssh user@$STATIC_IP "chmod u+x traefik/traefik.sh"
    ssh user@$STATIC_IP odoo/odoo.sh
    ssh user@$STATIC_IP traefik/traefik.sh
else
    echo "Le programme arrête la configuration ici car le nom de la VM n'est pas connu"
fi