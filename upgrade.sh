#!/bin/bash

#Feito por Matheus Rafael
#Atualizado em 05/2025

#Troca as cores
green=$(tput setaf 2)
blue=$(tput setaf 6)
red=$(tput setaf 1)
reset=$(tput sgr0)

#Variaveis postgresql.conf
TOTALM=`free -m | head -n 2 | tail -n 1 | awk {'print $2'}`
SHABM=`echo $(( TOTALM*25/100 ))`
ECSM=`echo $(( TOTALM*75/100 ))`

echo -e "\n ${green} ### SCRIPT INICIADO! ### ${reset} \n "

# Etapa 1: Obter as versões do usuário
$oldpost
$newpost
$currentDir
$newdir
            


read -p "${blue}Digite a versão ATUAL do PostgreSQL: ${reset}" oldpost
echo -e "\n" 
read -p "${blue}Digite a versão NOVA DESEJADA do PostgreSQL: ${reset}" newpost
echo -e "\n"
read -p "${blue}Digite o diretório DATA ATUAL do PostgreSQL: ${reset}" currentDir
echo -e "\n"
read -p "${blue}Digite o DIRETÓRIO NOVO do PostgreSQL: (exemplo: /home, /dados, /banco: ${reset}" newdir

# Exibir confirmação
echo -e "\n ${green}Versão antiga:${reset} $oldpost \n \n ${green}Versão nova:${reset} $newpost \n \n ${green}Diretório atual:${reset} $currentDir \n \n ${green}Diretório novo:${reset} $newdir  ${reset} \n"

read -p "${blue}Deseja continuar com a configuração? (Y/n): ${reset}" response

if [[ "$response" =~ ^[Nn] ]]; then
    echo "${green}[CANCELADO] Operação cancelada.${reset}"
    exit 1
fi

# Etapa 2: Atualizar repositórios e instalar PostgreSQL
echo -e "\n${green}[PROCESSO EM ANDAMENTO] Instalando e configurando nova versão do PostgreSQL${reset}"
# Adiciona a chave GPG
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &> /dev/null

# Adiciona o repositório
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list &> /dev/null

# Atualiza os repositórios
sudo apt update &> /dev/null

# Instala o PostgreSQL
sudo apt install postgresql-$newpost postgresql-client-$newpost -y &> /dev/null

#Corrigir a falha de novos linux não subir o cluster novo
echo "${green}[PROCESSO EM ANDAMENTO] Verificando cluster da nova versão $newpost ${reset}"

if pg_lsclusters | grep -q "$newpost.*main.*online"; then
    echo "${green}[PROCESSO EM ANDAMENTO] Cluster $newpost já está ativo.${reset}"
else
    echo "${red}[PROCESSO EM ANDAMENTO] Cluster $newpost não está ativo. Tentando ativar...${reset}"

    pg_createcluster $newpost main --start
    sleep 10
    if pg_lsclusters | grep -q "$newpost.*main.*online"; then
        echo "${green}[PROCESSO EM ANDAMENTO] Cluster $newpost iniciado com sucesso.${reset}"
    else
        echo "${red}[CANCELADO] Falha ao iniciar o cluster $newpost. Saindo do script.${reset}"
        exit 1
    fi
fi

# Etapa 3: Criar pastas e modificar parâmetros
echo "${green}[PROCESSO EM ANDAMENTO] Criando diretorio postgres$newpost ${reset}"

# Criar diretório
mkdir $newdir/postgres$newpost/data -p &> /dev/null

# Ajustar proprietário
chown -R postgres:postgres $newdir/postgres$newpost &> /dev/null

# Copiar dados do binario padrão para o novo
cp -Rf /var/lib/postgresql/$newpost/main/* $newdir/postgres$newpost/data &> /dev/null

# Navegar até o diretório
cd $newdir/postgres$newpost/

# Ajustar proprietário novamente
chown -R postgres:postgres * &> /dev/null

# Voltar ao diretório inicial
cd $newdir

# Ajustar permissões
chmod 700 postgres$newpost -Rf &> /dev/null

echo -e "\n${green}[PROCESSO EM ANDAMENTO] Configuração novo ambiente PostgreSQL concluída com sucesso! ${reset}"

#Ajustando configurações no antigo postgreSQL
#Necessário o usuário postgres ser SUPERUSER e com permissões de login (retirado ao final do processo por questões Security)
echo "${green}[PROCESSO EM ANDAMENTO] Iniciando configurações do PostgreSQL $oldpost ${reset}"
/usr/lib/postgresql/$oldpost/bin/psql -d postgres -U admin -c "ALTER ROLE postgres WITH SUPERUSER LOGIN;" &> /dev/null

##Ajustando configurações no novo postgreSQL 
echo "${green}[PROCESSO EM ANDAMENTO] Iniciando configurações do PostgreSQL $newpost ${reset}"
cd /etc/postgresql/$newpost/main/

#Backup do arquivo original pg_hba.conf
cp pg_hba.conf pg_hba.conf.default &> /dev/null

#Copiando pg_hba.conf antigo para versão nova (manter liberado os mesmos hosts)
cp /etc/postgresql/$oldpost/main/pg_hba.conf /etc/postgresql/$newpost/main/ &> /dev/null

#Backup do arquivo original postgresql.conf
cp postgresql.conf postgresql.conf.default &> /dev/null

#Ajuste dos parametros essenciais do postgresql.conf (pg_tune)
sed -i -e "s/#idle_in_transaction_session_timeout = 0/idle_in_transaction_session_timeout = 20000/" postgresql.conf
sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" postgresql.conf
sed -i -e "s/#deadlock_timeout = 1s/deadlock_timeout = 5s/" postgresql.conf
sed -i -e "s/#max_locks_per_transaction = 64/max_locks_per_transaction = 128/" postgresql.conf
sed -i -e "s/shared_buffers = 128MB/shared_buffers = $(( SHABM ))MB/" postgresql.conf # Memoria compartilhada (≈25% RAM)            	
sed -i -e "s/#effective_cache_size = 4GB/effective_cache_size = $(( ECSM ))MB/" postgresql.conf # # Cache efetivo (≈75% RAM)
sed -i -e "s/max_connections = 100/max_connections = 600/" postgresql.conf
sed -i -e "s/#synchronous_commit = on/synchronous_commit = off/" postgresql.conf
sed -i -e "s/#checkpoint_segments = 3/checkpoint_segments = 10/" postgresql.conf
sed -i -e "s/#maintenance_work_mem = 64MB/maintenance_work_mem = 512MB/" postgresql.conf
sed -i -e "s|data_directory = '/var/lib/postgresql/$newpost/main'|data_directory = '$newdir/postgres$newpost/data/'|" postgresql.conf
sed -i -e "s|port = 5433 |port = 50432|" postgresql.conf

set PGCLIENTENCODING=utf-8
touch $newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null
chown -R postgres:postgres * &> /dev/null
chown -R postgres:postgres $newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null
chmod 700 * &> /dev/null
chmod 777 $newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null

#Restart dos serviços postgreSQL Antigos e novos para subir novos clusters
/etc/init.d/postgresql restart &> /dev/null

#Copiando os arquivos
echo "${green}[PROCESSO EM ANDAMENTO] Copiando arquivos de configuração PostgreSQL $oldpost ${reset}"
cp -Rf /etc/postgresql/$oldpost/main/postgresql.conf $currentDir/ &> /dev/null
cp -r /etc/postgresql/$oldpost/main/conf.d $currentDir/ &> /dev/null
cd $currentDir/
chown -R postgres:postgres postgresql.conf &> /dev/null
chown -R postgres:postgres conf.d &> /dev/null

echo "${green}[PROCESSO EM ANDAMENTO] Copiando arquivos de configuração PostgreSQL $newpost ${reset}" 
cp /etc/postgresql/$newpost/main/postgresql.conf $newdir/postgres$newpost/data/ &> /dev/null
cp -r /etc/postgresql/$newpost/main/conf.d $newdir/postgres$newpost/data/ &> /dev/null
cd $newdir/postgres$newpost/data/ &> /dev/null
chown -R postgres:postgres postgresql.conf
chown -R postgres:postgres conf.d

# Inicio de processo de upgrade
# Dentro do bloco EOF irá ser realizado com o usuário postgres
sudo -u postgres /bin/bash <<EOF

#Parando os clusters  

echo "${green}[PROCESSO EM ANDAMENTO] Parando serviços de clusters ${reset}"
/usr/lib/postgresql/$oldpost/bin/pg_ctl stop -D "$currentDir" &> /dev/null
/usr/lib/postgresql/$newpost/bin/pg_ctl stop -D "$newdir/postgres$newpost/data" &> /dev/null

cd $newdir/postgres$newpost/data/
echo "${green} [PROCESSO EM ANDAMENTO] Iniciando processo de upgrade ${reset}"
echo "\n ${red} #### POR SEGURANÇA, NÃO STOPAR ESSE PROCESSO #### ${reset}"
/usr/lib/postgresql/$newpost/bin/pg_upgrade -b "/usr/lib/postgresql/$oldpost/bin" -B "/usr/lib/postgresql/$newpost/bin" -d "$currentDir" -D "/$newdir/postgres$newpost/data" -Upostgres #Aparecer na tela o resultado
EOF

# Alterando parametros de portas
/etc/init.d/postgresql start &> /dev/null
cd /etc/postgresql/$newpost/main/
sed -i -e "s|port = 5433|port = 5432| " postgresql.conf
#/etc/init.d/postgresql restart &> /dev/null
cd /etc/postgresql/$oldpost/main/
sed -i -e "s|port = 5432|port = 5433| " postgresql.conf
/etc/init.d/postgresql restart &> /dev/null

# Manutenções após finalizar Upgrade
cd $newdir/postgres$newpost/data/
echo -e "\n \n ${green}#### Processo concluído. Caso não houver erros acima, finalizado com sucesso. ####${reset}"
#
echo -e "\n \n [INFO] Recomendado executar: ${red} /usr/lib/postgresql/$newpost/bin/vacuumdb -U postgres --all --analyse-in-stages ${reset}"

#Opcional após upgrade
cd $newdir/postgres$newpost/data
/usr/lib/postgresql/$newpost/bin/psql -d postgres -U admin -f update_extensions.sql &> /dev/null
/usr/lib/postgresql/$newpost/bin/psql -d postgres -U admin -c "ALTER ROLE postgres WITH NOSUPERUSER NOLOGIN;" &> /dev/null
echo -e " \n \n${green}[INFO] Após validações, acesse o diretório $newdir/postgres$newpost/data/ e execute o seguinte script para deletar o cluster da versão anterior: ./delete_old_cluster.sh ${reset}\n "
echo -e "\n${red}[CUIDADO] AO EXECUTAR O SCRIPT ./delete_old_cluster.sh, NÃO SERÁ POSSÍVEL REALIZAR UM ROLLBACK PARA A VERSÃO ANTERIOR. ${reset}\n"

exit
