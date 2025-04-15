# Projeto de Atualização PostgreSQL (pg_upgrade)

Este projeto foi desenvolvido para facilitar o processo de upgrade de uma versão antiga do PostgreSQL para uma versão mais nova. O script realiza uma série de operações, incluindo instalação de novas versões, cópia de diretórios de dados e ajustes nas configurações do PostgreSQL.

## Funcionalidades

- Instalação de uma nova versão do PostgreSQL com base na versão informada pelo usuário.
- Criação de diretórios e ajuste de permissões para o novo ambiente.
- Configuração automática de parâmetros do `postgresql.conf` para otimizar o desempenho.
- Processo automatizado de `pg_upgrade` para migrar dados do PostgreSQL antigo para o novo.
- Reinicialização de serviços e ajuste das portas de comunicação entre as versões antiga e nova.
- Execução de `VACUUM` e outras manutenções pós-upgrade.

## Requisitos

- Sistema operacional Linux com suporte ao PostgreSQL.
- Acesso administrativo (`sudo`) ao sistema para instalar pacotes e modificar permissões de diretórios.
- O script foi testado no ambiente com suporte ao gerenciador de pacotes `apt` (Debian/Ubuntu).
- PostgreSQL a partir da versão 12 e instalado via repositório.

## Como usar

1. Clone o repositório ou copie o script para seu ambiente.
2. Certifique-se de ter as permissões necessárias para executar comandos como `sudo`.
3. Execute o script:
   ```bash
   ./upgrade.sh
   ```
4. Siga as instruções na tela, informando as versões e diretórios conforme solicitado.

## Parâmetros

* **Versão antiga** : Versão atual instalada do PostgreSQL.
* **Versão nova** : Versão para a qual você deseja atualizar o PostgreSQL.
* **Diretório atual** : Diretório onde o PostgreSQL atual está armazenando os dados.
* **Diretório novo** : Diretório onde o PostgreSQL novo irá armazenar os dados.

## Atenção

* Este script realiza alterações diretas em arquivos de configuração do PostgreSQL e manipula permissões de diretórios. Verifique cuidadosamente antes de executar em ambientes de produção.
* É recomendado realizar um backup completo do ambiente antes de iniciar o processo de upgrade.

## Autor

* Desenvolvido por Matheus Rafael.

## Licença

* Uso restrito para fins de estudo e adaptação em ambientes controlados. Não é recomendada a utilização em ambientes de produção sem antes realizar os devidos testes e validações.
