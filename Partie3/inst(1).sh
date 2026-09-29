#!/bin/bash
echo "=== Nettoyage de l'environnement ==="
docker rm -f ubuntu-serveur 2>/dev/null
docker network rm reseau_samba_vray 2>/dev/null

echo "=== Q1 : Création du réseau ==="
docker network create --subnet=172.17.0.0/16 reseau_samba_vray

echo "=== Q2 : Démarrage du conteneur Ubuntu ==="
docker run -d --privileged --hostname samba-srv --name ubuntu-serveur --network reseau_samba_vray --ip 172.17.0.3 ubuntu tail -f /dev/null

echo "=== Q3 : Installation des paquets ==="
docker exec ubuntu-serveur apt-get update
# DEBIAN_FRONTEND=noninteractive permet de ne pas avoir de pop-ups bloquants pendant l'installation
docker exec -e DEBIAN_FRONTEND=noninteractive ubuntu-serveur apt-get install -y samba smbclient cifs-utils nano net-tools iputils-ping

echo "=== Q4 : Création des répertoires ==="
docker exec ubuntu-serveur mkdir -p /partage/amoi /partage/atoi /partage/anous /partage/public /partage/amoi-atoi /partage/amoi-anous

echo "=== Q5 : Création des groupes avec samba-tool ==="
docker exec ubuntu-serveur samba-tool group add cmoi
docker exec ubuntu-serveur samba-tool group add ctoi
docker exec ubuntu-serveur samba-tool group add cnous

echo "=== Q6 : Création des comptes avec samba-tool ==="
# Utilisation d'un mot de passe simple sans caractères spéciaux complexes pour éviter les erreurs bash
docker exec ubuntu-serveur samba-tool user create moi 'Lubin2026*' --given-name=Moi --login-shell=/bin/bash
docker exec ubuntu-serveur samba-tool user create toi 'Lubin2026*' --given-name=Toi --login-shell=/bin/bash
docker exec ubuntu-serveur samba-tool user create nous 'Lubin2026*' --given-name=Nous --login-shell=/bin/bash

echo "=== Q7 : Ajout des utilisateurs à leurs groupes ==="
docker exec ubuntu-serveur samba-tool group addmembers cmoi moi
docker exec ubuntu-serveur samba-tool group addmembers ctoi toi
docker exec ubuntu-serveur samba-tool group addmembers cnous nous

echo "=== Application des droits Linux sur les répertoires ==="
# Attribution des groupes
docker exec ubuntu-serveur chgrp cmoi /partage/amoi /partage/amoi-atoi /partage/amoi-anous
docker exec ubuntu-serveur chgrp ctoi /partage/atoi
docker exec ubuntu-serveur chgrp cnous /partage/anous
# Permissions (770 = full pour proprio/groupe, rien pour les autres. 777 = tout pour tous)
docker exec ubuntu-serveur chmod 770 /partage/amoi /partage/atoi /partage/anous /partage/amoi-atoi /partage/amoi-anous
docker exec ubuntu-serveur chmod 777 /partage/public

echo "=== Q8 : Création du fichier smb.conf ==="
docker exec ubuntu-serveur bash -c 'cat > /etc/samba/smb.conf <<EOF
[global]
   workgroup = WORKGROUP
   server role = standalone server
   security = user
   map to guest = bad user

[public]
   path = /partage/public
   read only = no
   guest ok = yes

[amoi]
   path = /partage/amoi
   valid users = @cmoi @ctoi @cnous
   write list = @cmoi

[atoi]
   path = /partage/atoi
   valid users = @ctoi @cmoi
   write list = @ctoi

[anous]
   path = /partage/anous
   valid users = @cnous @cmoi @ctoi
   write list = @cnous

[amoi-atoi]
   path = /partage/amoi-atoi
   valid users = @cmoi @ctoi
   write list = @cmoi

[amoi-anous]
   path = /partage/amoi-anous
   valid users = @cmoi @cnous
   write list = @cmoi
EOF'

echo "=== Démarrage du service Samba ==="
docker exec ubuntu-serveur service smbd start
docker exec ubuntu-serveur service nmbd start

echo "=== Q9 : Testparm ==="
docker exec ubuntu-serveur testparm -s

echo "=== Q10 : Test de connexion smbclient ==="
echo "Test d'accès au dossier 'amoi' avec l'utilisateur 'moi' :"
docker exec ubuntu-serveur smbclient //172.17.0.3/amoi -U moi%Lubin2026* -c 'ls; exit'