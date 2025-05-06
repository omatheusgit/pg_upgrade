# Projeto de Atualização PostgreSQL (pg_upgrade)

Este projeto automatiza a migração de uma versão antiga do PostgreSQL para uma versão mais nova, cuidando de instalação, migração de dados e ajustes de configuração.

## Funcionalidades

- **Instalação** automática da versão nova informada pelo usuário.  
- **Criação** de diretórios e ajuste de permissões para o novo cluster.  
- **Otimizações** pré-configuradas no `postgresql.conf` (buffers, cache, timeouts, logs, timezone).  
- **Migração** de dados via `pg_upgrade`, parando/ativando clusters conforme necessário.  
- **Ajuste** de portas para coexistência das versões antiga e nova.  
- **Vacuum** e outras manutenções pós-upgrade.

## Requisitos

- Linux (Debian/Ubuntu) com gerenciador de pacotes `apt`.  
- Acesso administrativo (`sudo`).  
- PostgreSQL ≥ 12 disponível nos repositórios oficiais.

## Como usar

```bash
git clone https://github.com/omatheusgit/pg_upgrade.git
cd pg_upgrade
chmod +x upgrade.sh
./upgrade.sh
```

> **Dica:** Siga as instruções na tela, informando as versões e diretórios conforme solicitado. Leia atentamente os processos que estão sendo executados e exibidos em tela.

   
## Parâmetros solicitados

- **Versão antiga**: versão atualmente em uso do PostgreSQL.  
- **Versão nova**: versão desejada para upgrade.  
- **Diretório atual**: local dos dados da versão antiga (data dir).  
- **Diretório novo**: pasta/destino da nova versão do PostgresSQL.

## Atenção

- Faça **backup completo** antes de iniciar.  
- Teste em **ambiente controlado**; não execute direto em produção.  
- Revise os parâmetros do `postgresql.conf` caso tenha necessidades específicas de carga de trabalho.

## Autor

* Desenvolvido por **Matheus Rafael**. <img src="https://media.giphy.com/media/mKHdmq1QR9Dvq/giphy.gif" alt="Batman GIF" width="60" height="40" />



