#!/bin/bash
#inserir aqui

#fixo
tt=`/bin/date +%d%m%y%H%M%S`

banner(){
  clear
  printf "\n"
  printf "\n\n";
  printf " ██████   ██████            ████   █████     ███ \n";
  printf "░░██████ ██████            ░░███  ░░███     ░░░  \n";
  printf " ░███░█████░███  █████ ████ ░███  ███████   ████ \n";
  printf " ░███░░███ ░███ ░░███ ░███  ░███ ░░░███░   ░░███ \n";
  printf " ░███ ░░░  ░███  ░███ ░███  ░███   ░███     ░███ \n";
  printf " ░███      ░███  ░███ ░███  ░███   ░███ ███ ░███ \n";
  printf " █████     █████ ░░████████ █████  ░░█████  █████\n";
  printf "░░░░░     ░░░░░   ░░░░░░░░ ░░░░░    ░░░░░  ░░░░░ \n";
  printf "                                                 \n";
  printf "       ████     █████       █████                \n";
  printf "      ░░███   ███░░░███   ███░░░███              \n";
  printf "       ░███  ███   ░░███ ███   ░░███             \n";
  printf "       ░███ ░███    ░███░███    ░███             \n";
  printf "       ░███ ░███    ░███░███    ░███             \n";
  printf "       ░███ ░░███   ███ ░░███   ███     Update   \n";
  printf "       █████ ░░░█████░   ░░░█████░      v1.1.3   \n";
  printf "      ░░░░░    ░░░░░░      ░░░░░░     26/08/2023 \n";
}

system_set_confirmacao() {
  printf "\n\n"
  printf "\n\n"
  printf "${WHITE} 💻 Vai iniciar o Backup do Postgres Banco multi100, vai precisar digitar a senha do banco de dados... ..${GRAY_LIGHT}"
  printf "\n\n"
  printf "${WHITE} 💻 Sua senha será mostrada na linha abaixa..é o texto depois do =       EXEMPLO  DB_PASS=multi100multi ${GRAY_LIGHT}"
  printf "\n\n"
  printf "${WHITE} 💻 Assim que Visualizar a Senha digite SIM para prosseguir ${GRAY_LIGHT}"
  printf "\n\n"
  printf "\n\n"
  printf "\n\n"
  sudo su - root <<EOF
  grep "DB_PASS=" /home/deploy/multi100/backend/.env 
EOF
  printf "\n\n"
  printf "\n\n"
  printf "\n\n"
 echo "Digite SIM para continuar ou qualquer outra coisa para terminar"
read resp
if [ $resp. != 'SIM.' ]; then
    exit 0
fi

}

system_set_pastabackup() {
  printf "\n\n"
  printf "\n\n"
  printf "${WHITE} 💻 Verificando e Criando Pasta /home/deploy/multi100/backup..${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - root <<EOF
  if [ ! -d /home/deploy/multi100/backup ]; then
    mkdir /home/deploy/multi100/backup
fi
EOF
}

system_set_backup() {
  printf "\n\n"
  printf "\n\n"
  printf "${WHITE} 💻 Backup do Banco de Dados Postress /home/deploy/multi100/backup..${GRAY_LIGHT}"
  printf "\n\n"
  printf "${WHITE} 💻 Sua Senha Abaixo ${GRAY_LIGHT}"
  printf "\n\n"
  printf "\n\n"
  printf "\n\n"
  sudo su - root <<EOF
  grep "DB_PASS=" /home/deploy/multi100/backend/.env 
EOF
  printf "\n\n"
  printf "\n\n"
  printf "\n\n"

  sudo su - root <<EOF
  chown deploy -R /home/deploy/multi100/backup
  chmod 775 -R /home/deploy/multi100/backup/

  pg_dump multi100 -p 5432  -U multi100 -h 127.0.0.1 -f /home/deploy/multi100/backup/$tt.bkp

  sleep 10
EOF
}

system_set_updatemulti100() {
  printf "\n\n"
  printf "\n\n"
  printf "${WHITE} 💻 Atualizando Multi100..${GRAY_LIGHT}"
  printf "\n\n"

  sudo su - root <<EOF
    if [ ! -d /home/deploy/multi100/backup/public/$tt ]; then
    mkdir /home/deploy/multi100/backup/public/$tt
fi
EOF

  sudo su - root <<EOF
    if [ ! -d /home/deploy/multi100/backup/assets/$tt ]; then
    mkdir /home/deploy/multi100/backup/assets/$tt
fi
EOF

  sudo su - root <<EOF
  chown deploy -R /home/deploy/multi100/backup/
  chmod 775 -R /home/deploy/multi100/backup/
EOF
sudo su - deploy <<EOF
  rsync -Cravzp  /home/deploy/multi100/frontend/public/ /home/deploy/multi100/backup/public/$tt
  rsync -Cravzp  /home/deploy/multi100/frontend/src/assets/ /home/deploy/multi100/backup/assets/$tt
EOF

sudo su - deploy <<EOF
  cd /home/deploy/multi100
  git reset --hard
  git pull
  sleep 10
  printf "${WHITE} 💻 Atualizando Backend..${GRAY_LIGHT}"
  cd /home/deploy/multi100/backend
  rm node_modules -rf 
  npm install
  sleep 10
  pm2 restart all
  printf "${WHITE} 💻 Atualizando Banco..${GRAY_LIGHT}"
  sleep 10
  npx sequelize db:migrate
  sleep 10
  npx sequelize db:seed
  printf "\n\n"
  printf "\n\n"
  sleep 10
  printf "${WHITE} 💻 Atualizando Frontend..${GRAY_LIGHT}"
  sleep 10
  cd /home/deploy/multi100/frontend
  rsync -Cravzp  /home/deploy/multi100/backup/public/$tt /home/deploy/multi100/frontend/public/ 
  rsync -Cravzp  /home/deploy/multi100/backup/assets/$tt /home/deploy/multi100/frontend/src/assets/ 
  npm install -f
  npm run build
  sleep 10
  pm2 restart all
EOF
}

success(){
  printf "\n\n"
  printf "\n\n"
  printf " 💻 Backup/Update do Banco e Update do Multi100 concluída...\n"
  printf "\n\n"
}

exec_all() {
  system_set_confirmacao
  system_set_pastabackup
  system_set_backup
  system_set_updatemulti100
  success
}
exec_all

