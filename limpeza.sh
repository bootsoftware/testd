#!/bin/bash

# Verificando se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado como root (ou com privilégios de superusuário)."
  exit 1
fi

# Parando e removendo o serviço do PostgreSQL, se estiver instalado
if command -v systemctl >/dev/null 2>&1; then
  systemctl stop postgresql
  systemctl disable postgresql
else
  service postgresql stop
  update-rc.d postgresql remove
fi

# Removendo o PostgreSQL
apt-get -y remove --purge postgresql*

# Parando e removendo o serviço do Redis, se estiver instalado
if command -v systemctl >/dev/null 2>&1; then
  systemctl stop redis-server
  systemctl disable redis-server
else
  service redis-server stop
  update-rc.d redis-server remove
fi

# Removendo o Redis
apt-get -y remove --purge redis-server*

# Parando e removendo o serviço do Nginx, se estiver instalado
if command -v systemctl >/dev/null 2>&1; then
  systemctl stop nginx
  systemctl disable nginx
else
  service nginx stop
  update-rc.d nginx remove
fi

# Removendo o Nginx
apt-get -y remove --purge nginx*

# Parando o PM2 e removendo todas as instâncias
su - deploy -c "pm2 kill"
su - deploy -c "pm2 delete all"

# Verificando e matando todos os processos do usuário "deploy"
killall -u deploy

# Removendo o PM2 globalmente
npm uninstall -g pm2

# Removendo o usuário "deploy" e seu diretório home
userdel -r deploy

# Removendo vestígios do usuário "deploy"
rm -rf /home/deploy

# Remoção do Certbot e limpeza de vestígios da pasta /etc/letsencrypt
apt-get -y remove --purge certbot*
rm -rf /etc/letsencrypt

# Parando e removendo todos os containers Docker, se houver
if command -v docker >/dev/null 2>&1; then
  docker stop $(docker ps -aq) >/dev/null 2>&1
  docker rm $(docker ps -aq) >/dev/null 2>&1
fi

# Removendo todas as imagens Docker, se houver
if command -v docker >/dev/null 2>&1; then
  docker rmi $(docker images -aq) >/dev/null 2>&1
fi

# Desinstalando o Docker e o Docker Compose, se estiverem instalados
if command -v docker >/dev/null 2>&1; then
  apt-get -y purge docker-ce docker-ce-cli containerd.io
  rm -rf /var/lib/docker
  rm -rf /etc/docker
  rm -rf /usr/local/bin/docker-compose
fi

# Remoção do snapd e limpeza dos vestígios
if command -v snap >/dev/null 2>&1; then
  systemctl stop snapd.service snapd.socket
  systemctl disable snapd.service snapd.socket
  apt-get -y remove --purge snapd
fi

# Desinstalando o Node.js e limpando os vestígios
pkill -u root node
apt-get -y remove --purge nodejs npm
rm -rf /usr/local/lib/node*
rm -rf /usr/local/bin/node
rm -rf /usr/local/bin/npm

# Limpando pacotes e dependências não utilizados
apt-get -y autoremove
apt-get -y autoclean

echo -e "\e[32mRemoção completa do PostgreSQL, Redis, Nginx, PM2, Certbot, Docker, Snapd e do usuário deploy concluída.\e[0m"
