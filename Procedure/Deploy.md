# Procédure sur l'utilisation et l'explication du script de déploiement des machines
## L'utilisation du script
Tout d'abord, avant d'utiliser le script de déploiement des machines, nous allons vous donner quelques instructions.

Si le dossier avec le script se trouve sur la machine **dattier**, alors vous pouvez passer à l'étape suivante.

Si cela n'est pas le cas, deux solutions s'offrent à vous.

La première consiste à se connecter sur dattier via la commande `ssh` puis de cloner le dossier avec la commande `git clone`.

```bash
# Connexion à dattier
login@phys$ ssh virt

login@phys$ ssh dattier.iutinfo.fr

# Clonage du dépôt git
login@virtu$ git clone "Lien du dépôt"
```

La deuxième solution est de cloner le dépôt git sur votre PC puis de le transférer vers la machine **dattier** via la commande `scp`.

```bash
# Clonage du dépôt git
login@phys$ git clone "Lien du dépôt"

# Transfert du dossier vers dattier
login@phys$ scp -r j-souliez-keller virt:~

login@phys$ scp -r j-souliez-keller dattier.iutinfo.fr:~

# Connexion à dattier
login@phys$ ssh virt

login@phys$ ssh dattier.iutinfo.fr
```

Une fois que le dossier est sur la machine dattier, vous êtes prêt à utiliser le script [deploy.sh](../deploy.sh).

### Lancement du script *deploy.sh*
Pour utiliser le script, cela est très simple, vous avez juste à taper la commande suivante :
```bash
login@virtu$ cd j-souliez-keller

login@virtu$ ./deploy.sh
```

## Explication du script
Lors du lancement du script, celui-ci script commencera par vous demander de fournir un nom pour votre machine virtuelle ainsi qu'une adresse IP.
```bash
printf "\n\nQuel nom souhaitez vous donner à votre machine virtuelle. \nUne fois le nom entré, tapez sur la touche 'entrer' pour confirmer.\n"
read MACHINE_NAME
echo Vous avez decider de nommer votre machine avec le nom suivant: $MACHINE_NAME

printf "\n\nQuelle adresse souhaitez vous attribuer à votre machine virtuelle. \nUne fois le nom entré, tapez sur la touche 'entrer' pour confirmer.\n"
read STATIC_IP
echo L\'adresse IP de la machine sera: $STATIC_IP
```

Une fois que vous avez décidé du nom et de l'adresse IP, le script créera la machine virtuelle avec ces paramètres et la démarrera.
```bash
vmiut creer $MACHINE_NAME && vmiut start $MACHINE_NAME
```

Le script surveillera en boucle jusqu'à ce que l'adresse IP de la machine virtuelle soit attribuée. Une fois l'adresse IP attribuée, le script la récupérera et l'affichera.
```bash
# On boucle tant que l'ip n'est pas attribuée
while [[ -z "$(vmiut info $MACHINE_NAME | grep 'ip-possible=' | cut -d '=' -f 2)" ]];
do
    sleep 1
done

# On stocke l'ip automatique de la machine
IP_AUTOMATIQUE=$(vmiut info $MACHINE_NAME | grep 'ip-possible=' | cut -d '=' -f 2)
echo L\'adresse ip de la machine est: $IP_AUTOMATIQUE
```

Une clé SSH sera générée pour la machine virtuelle. Vous devrez entrer le mot de passe de l'utilisateur pour copier la clé publique vers la machine virtuelle.
```bash
ssh-keygen -f ~/.ssh/known_hosts -R "$IP_AUTOMATIQUE"
printf "\n\nPour implémenter votre clé publique dans $MACHINE_NAME, veuillez saisir le mot de passe suivant :\nuser\n\n"
ssh-copy-id user@$IP_AUTOMATIQUE
```

Le script configurera les fichiers interfaces, hosts et hostname avec l'adresse IP choisie. Il transférera ces fichiers vers la machine virtuelle.
```bash
printf "source /etc/network/interfaces.d/*\n\nauto lo\niface lo inet loopback\n\nallow-hotplug enp0s3\niface enp0s3 inet static\n  address $STATIC_IP/16\n  gateway 10.42.0.1\n" > config_machine/interfaces
printf "127.0.0.1       localhost\n127.0.1.1       $MACHINE_NAME\n\n::1     localhost ip6-localhost ip6-loopback\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\n" > config_machine/hosts
printf $MACHINE_NAME > config_machine/hostname

printf "\n\nSi vous êtes invité à fournir le mot de passe de l'utilisateur, veuillez entrer :\nuser\n\n"

scp config_machine/interfaces user@$IP_AUTOMATIQUE:~
scp config_machine/hosts user@$IP_AUTOMATIQUE:~
scp config_machine/hostname user@$IP_AUTOMATIQUE:~
scp config_machine/move.sh user@$IP_AUTOMATIQUE:~
```

Le script exécutera un script move.sh sur la machine virtuelle pour changer l'adresse IP et le nom d'hôte. Vous devrez entrer le mot de passe root pour effectuer cette opération.
```bash
ssh user@$IP_AUTOMATIQUE "chmod u+x move.sh"
printf "\nVeuillez entrer le mot de passe suivant pour changer l'IP et le hostname :\n\nroot\n\n"
ssh user@$IP_AUTOMATIQUE "su -c ./move.sh"
```

La machine virtuelle sera arrêtée puis redémarrée.
```bash
sleep 5
vmiut stop $MACHINE_NAME

sleep 10
vmiut start $MACHINE_NAME
```