#!/bin/bash

#Feito por Matheus Rafael - Wareline 2023
#Atualizado em 03/2025

#Troca as cor
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
read -p "${blue}Digite o diretório atual do PostgreSQL: ${reset}" currentDir
echo -e "\n"
read -p "${blue}Digite o nome do novo diretório do PostgreSQL: (exemplo: home, dados, banco. SEM O '/' ${reset}" newdir

# Exibir confirmação
echo -e "\n ${green}Versão antiga: $oldpost \n \n Versão nova: $newpost \n \n Diretório atual: $currentDir \n \n Diretório novo: $newdir  ${reset} \n"

read -p "${blue}Deseja continuar com a configuração? (Y/n): ${reset}" response

if [[ "$response" =~ ^[Nn] ]]; then
    echo "${green}Operação cancelada.${reset}"
    exit 1
fi

# Etapa 2: Atualizar repositórios e instalar PostgreSQL
echo -e "\n ${green}Instalando e configurando nova versão do PostgreSQL${reset}"
# Adiciona a chave GPG
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg &> /dev/null

# Adiciona o repositório
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list &> /dev/null

# Atualiza os repositórios
sudo apt update &> /dev/null

# Instala o PostgreSQL
sudo apt install postgresql-$newpost postgresql-client-$newpost -y &> /dev/null

#Corrigir a falha de novos linux não subir o cluster novo
echo "${green}Verificando cluster da nova versão $newpost ${reset}"

if pg_lsclusters | grep -q "$newpost.*main.*online"; then
    echo "${green}Cluster $newpost já está ativo.${reset}"
else
    echo "${red}Cluster $newpost não está ativo. Tentando ativar...${reset}"

    pg_createcluster $newpost main --start
    sleep 10
    if pg_lsclusters | grep -q "$newpost.*main.*online"; then
        echo "${green}Cluster $newpost iniciado com sucesso.${reset}"
    else
        echo "${red}Falha ao iniciar o cluster $newpost. Saindo do script.${reset}"
        exit 1
    fi
fi

# Etapa 3: Criar pastas e modificar parâmetros
echo "${green}Criando diretorio postgres$newpost ${reset}"
# Criar diretórios
mkdir /$newdir/postgres$newpost &> /dev/null
mkdir /$newdir/postgres$newpost/data &> /dev/null

# Ajustar proprietário
chown -R postgres:postgres /$newdir/postgres$newpost &> /dev/null

# Copiar dados do binario padrão para o novo
cp -Rf /var/lib/postgresql/$newpost/main/* /$newdir/postgres$newpost/data &> /dev/null

# Navegar até o diretório
cd /$newdir/postgres$newpost/

# Ajustar proprietário novamente
chown -R postgres:postgres * &> /dev/null

# Voltar ao diretório inicial
cd /$newdir

# Ajustar permissões
chmod 700 postgres$newpost -Rf &> /dev/null

echo -e "\n${green}Configuração novo ambiente PostgreSQL concluída com sucesso! ${reset}"

#Ajustando configurações no antigo postgreSQL 
echo "${green}Iniciando configurações do PostgreSQL $oldpost ${reset}"
/usr/lib/postgresql/$oldpost/bin/psql -d db1 -U PACIENTE -c "ALTER ROLE postgres WITH SUPERUSER;" &> /dev/null

##Ajustando configurações no novo postgreSQL 
echo "${green}Iniciando configurações do PostgreSQL $newpost ${reset}"
cd /etc/postgresql/$newpost/main/
cp pg_hba.conf pg_hba.conf.default &> /dev/null
cp /etc/postgresql/$oldpost/main/pg_hba.conf /etc/postgresql/$newpost/main/ &> /dev/null
cp postgresql.conf postgresql.conf.default &> /dev/null
sed -i -e "s/#idle_in_transaction_session_timeout = 0/idle_in_transaction_session_timeout = 20000/" postgresql.conf
sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" postgresql.conf
sed -i -e "s/#backslash_quote = safe_encoding/backslash_quote = on/" postgresql.conf
sed -i -e "s/#standard_conforming_strings = on/standard_conforming_strings = off/" postgresql.conf
sed -i -e "s/#deadlock_timeout = 1s/deadlock_timeout = 5s/" postgresql.conf
sed -i -e "s/#max_locks_per_transaction = 64/max_locks_per_transaction = 128/" postgresql.conf
##essas duas abaixo - se der problema no .conf
sed -i -e "s/shared_buffers = 128MB/shared_buffers = $(( SHABM ))MB/" postgresql.conf            	
sed -i -e "s/#effective_cache_size = 4GB/effective_cache_size = $(( ECSM ))MB/" postgresql.conf
sed -i -e "s/max_connections = 100/max_connections = 300/" postgresql.conf
sed -i -e "s/#synchronous_commit = on/synchronous_commit = off/" postgresql.conf
sed -i -e "s/#checkpoint_segments = 3/checkpoint_segments = 10/" postgresql.conf
sed -i -e "s/#maintenance_work_mem = 64MB/maintenance_work_mem = 512MB/" postgresql.conf
sed -i -e "s/#bytea_output = 'hex'/bytea_output = 'escape'/" postgresql.conf
sed -i -e "s/#log_destination = 'stderr'/log_destination = 'stderr'/" postgresql.conf
sed -i -e "s/#logging_collector = off/logging_collector = on/" postgresql.conf
sed -i -e "s/#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'/log_filename = 'postgresql-%a.log'/" postgresql.conf
sed -i -e "s|log_timezone = 'Etc/UTC'|log_timezone = 'America/Sao_Paulo'|" postgresql.conf
sed -i -e "s|timezone = 'Etc/UTC'|timezone = 'America/Sao_Paulo'|" postgresql.conf
sed -i -e "s|data_directory = '/var/lib/postgresql/$newpost/main'|data_directory = '/$newdir/postgres$newpost/data/'|" postgresql.conf
sed -i -e "s|port = 5433 |port = 50432|" postgresql.conf
sed -i -e "s/#track_activity_query_size = 1024/track_activity_query_size = 5000/" postgresql.conf
sed -i -e "s/escape_string_warning = off/escape_string_warning = on/" postgresql.conf

set PGCLIENTENCODING=utf-8
touch /$newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null
chown -R postgres:postgres * &> /dev/null
chown -R postgres:postgres /$newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null
chmod 700 * &> /dev/null
chmod 777 /$newdir/postgres$newpost/data/pg_upgrade_server.log &> /dev/null

#Restart dos serviços postgreSQL Antigos e novos para subir novos clusters
/etc/init.d/postgresql restart &> /dev/null

#Copiando os arquivos
echo "${green}Copiando arquivos de configuração PostgreSQL $oldpost ${reset}"
cp -Rf /etc/postgresql/$oldpost/main/postgresql.conf $currentDir/ &> /dev/null
cp -r /etc/postgresql/$oldpost/main/conf.d $currentDir/ &> /dev/null
cd $currentDir/
chown -R postgres:postgres postgresql.conf &> /dev/null
chown -R postgres:postgres conf.d &> /dev/null

echo "${green}Copiando arquivos de configuração PostgreSQL $newpost ${reset}" 
cp /etc/postgresql/$newpost/main/postgresql.conf /$newdir/postgres$newpost/data/ &> /dev/null
cp -r /etc/postgresql/$newpost/main/conf.d /$newdir/postgres$newpost/data/ &> /dev/null
cd /$newdir/postgres$newpost/data/ &> /dev/null
chown -R postgres:postgres postgresql.conf
chown -R postgres:postgres conf.d

# Inicio de processo de upgrade
# Dentro do bloco EOF irá ser realizado com o usuário postgres
sudo -u postgres /bin/bash <<EOF

#Parando os clusters  

echo "${green}Parando serviços de clusters ${reset}"
/usr/lib/postgresql/$oldpost/bin/pg_ctl stop -D "$currentDir" &> /dev/null
/usr/lib/postgresql/$newpost/bin/pg_ctl stop -D "/$newdir/postgres$newpost/data" &> /dev/null

cd /$newdir/postgres$newpost/data/
echo "${green} Iniciando processo de upgrade ${reset}"
echo " ${red} #### POR SEGURANÇA, NÃO STOPAR ESSE PROCESSO #### ${reset}"
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
cd /$newdir/postgres$newpost/data/
echo "${green}Iniciando Vacuum ${reset}"
#
echo -e "\n Executar: ${red} /usr/lib/postgresql/$newpost/bin/vacuumdb -U postgres --all --analyse-in-stages ${reset}"

#Opcional após upgrade
cd /$newdir/postgres$newpost/data
/usr/lib/postgresql/$newpost/bin/psql -d db1 -U PACIENTE -f update_extensions.sql &> /dev/null
/usr/lib/postgresql/$newpost/bin/psql -d db1 -U PACIENTE -c "ALTER ROLE postgres WITH NOSUPERUSER;" &> /dev/null
echo -e " \n \n ${green}Após validações rodar ./delete_old_cluster.sh ${reset}\n "

exit