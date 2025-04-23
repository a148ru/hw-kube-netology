#!/bin/sh


GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

: "${DBNAME:=racktables}"
: "${DBHOST:=mariadb}"
: "${DBUSER:=racktables}"
: "${DBPASS:=password123}"


printf "Run extract arhive\n"

tar -xz -C /opt -f /racktables.tar.gz

if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tExtract done!\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

printf "Movie files rackables dir\n"
mv /opt/RackTables-0.22.0 /opt/racktables

if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tMove done !\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

printf "Adding Plugins for Racktable Reports\n"
apk add git
git clone https://github.com/collabnix/racktables-contribs
cd racktables-contribs/extensions
cp -r plugins/* /opt/racktables/plugins/

if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tPlagins add !\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

if [ ! -e /opt/racktables/wwwroot/inc/secret.php ]; then
    cat > /opt/racktables/wwwroot/inc/secret.php <<EOF
<?php
\$pdo_dsn = 'mysql:host=${DBHOST};dbname=${DBNAME}';
\$db_username = '${DBUSER}';
\$db_password = '${DBPASS}';
\$user_auth_src = 'database';
\$require_local_account = TRUE;
# See https://wiki.racktables.org/index.php/RackTablesAdminGuide
?>
EOF
fi

chmod 0400 /opt/racktables/wwwroot/inc/secret.php
chown nobody:nogroup /opt/racktables/wwwroot/inc/secret.php

printf "Clear start"
rm -r /racktables-contribs
rm -f /racktables.tar.gz
if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tClear done !\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

printf "Init script done !\n"

printf "To initialize the db, first go to /?module=installer&step=5\n"