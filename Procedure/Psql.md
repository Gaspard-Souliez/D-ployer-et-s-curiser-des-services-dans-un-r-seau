# Procédure sur la création de la machine virtuelle PSQL et sa configuration

## Création de la machine psql
Pour créer la machine `psql`, suivez ces étapes simples :

1. **Exécution du Script de Déploiement :**
   - Pour créer la machine virtuelle, exécutez le script `deploy.sh` en utilisant la commande suivante :
     ```bash
     login@virtu$ ./deploy.sh
     ```

2. **Attribution du Nom et de l'Adresse IP :**
   - Lorsque le script vous demande le nom de la machine à attribuer, spécifiez `psql`. Sinon, la suite de l'installation ne sera pas exécutée.
   - Ensuite, entrez l'adresse IP que vous avez décidé de lui attribuer.

3. **Création de la Machine Virtuelle :**
   - Une fois les informations saisies, la machine virtuelle sera créée et configurée avec les paramètres par défaut.

4. **Installation de PostgreSQL :**
   - Lorsque le script identifie `psql`, il passe à l'installation et à la configuration de PostgreSQL.
   - Vous serez invité à fournir l'adresse IP attribuée ou à attribuer à `odoo`.

5. **Configuration de PostgreSQL :**
   - PostgreSQL sera installé avec succès.
   - Un utilisateur nommé `admin` sera ajouté avec le mot de passe `admin` et les privilèges de superutilisateur.
   - Une base de données nommée `admin`, dont `admin` est le propriétaire, sera créée.

6. **Configuration de pg_hba.conf :**
   - Le fichier `pg_hba.conf` sera édité pour autoriser l'accès de la machine `odoo` à PostgreSQL.

7. **Modification des Privilèges :**
   - Les privilèges de l'utilisateur `admin` seront modifiés pour lui permettre de créer des bases de données et des rôles.

8. **Redémarrage de PostgreSQL :**
   - Enfin, PostgreSQL sera redémarré pour appliquer les modifications.

Une fois ces étapes terminées, l'installation et la configuration de PostgreSQL pour la machine virtuelle `psql` seront terminées.