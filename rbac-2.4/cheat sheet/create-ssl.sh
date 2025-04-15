#!/bin/bash

###########
# quick creation of certificates for the user
# run ./create-ssl.sh <username>
# a148ru
# ToDo:
#   - переписать сообщения на английский
#   - переписать проверки выполнения шагов скрипта, добавить проверку существования файлов.
#   - перевисать выводы выполнения, сдклвть типовыми для всех шагов.
############

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
USER_NAME="tester"
WORK_DIR=$PWD
DIR_CA="/var/snap/microk8s/current/certs" # /etc/kubernetes/pki
PATH_CRT="${WORK_DIR}/.certs" #
CLUSTER_NAME="microk8s-local"

if [ -z $1 ]; then
  printf "\tUse name for user ${GREEN}${USER_NAME}${NC}\n"  
else
    USER_NAME=$1
fi

if [ ! -d "${WORK_DIR}/.certs" ]; then
    mkdir $WORK_DIR/.certs
    if [ $? -eq 0 ]; then
      printf "[ ${GREEN}OK!${NC} ]\tDirectory .certs create\n"
    else
      printf "${RED}Something went wrong!${NC}\n"
      printf "${?}\n"
      exit
    fi
else
  printf "[ ${GREEN}OK!${NC} ]\tDirectory .certs exists\n"
fi


printf "\tCreating user: ${USER_NAME}\n"

openssl genrsa -out $PATH_CRT/$USER_NAME.key 2048
if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tRSA key generated\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

openssl req -new -key $PATH_CRT/$USER_NAME.key -out $PATH_CRT/$USER_NAME.csr -subj "/CN=${USER_NAME}"
if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tRequest certificate create\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

sudo openssl x509 -req -in $PATH_CRT/$USER_NAME.csr -CA $DIR_CA/ca.crt -CAkey $DIR_CA/ca.key -CAcreateserial -out $PATH_CRT/$USER_NAME.crt -days 356
if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tThe certificate is signed\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

sudo chown $USER:$USER $PATH_CRT/$USER_NAME.crt
if [ $? -eq 0 ]; then
  printf "[ ${GREEN}OK!${NC} ]\tПрава на файл сертификата восстановлены\n"
else
  printf "[ ${RED}Fail!${NC} ]\n"
  exit
fi

kubectl config set-credentials $USER_NAME --client-certificate=$PATH_CRT/$USER_NAME.crt --client-key=$PATH_CRT/$USER_NAME.key

kubectl config set-context $USER_NAME-context --cluster=$CLUSTER_NAME --user=$USER_NAME

printf "${GREEN}Done!${NC}\n"
