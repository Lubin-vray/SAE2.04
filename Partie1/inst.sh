#!/bin/bash
# Indique que ce fichier s'éxécute avec bash (la ligne de commande que 
# vous utilisez actuellement)

# A éxécuter en tant que superutilisateur

# Mise à jour du cache du gestionnaire de paquet
# Le gestionnaire de paquet c'est comme le google store mais pour Linux
apt update

# Installation de git
apt install -y git

# Installation de Apache2, Php, Mariadb (remplace MySql)
apt install -y apache2 php mariadb-client mariadb-server

# Installation du lien entre php et mysql
apt install -y php-mysql

# Installation de zip
apt install -y zip

# Installation de modules php nécessaire à symfony
apt install -y php-xml php-mbstring php-intl php-json php-zip php-gd php-xml php-curl php-mysql

# Installation navigateur web en ligne de commande
apt install -y lynx
