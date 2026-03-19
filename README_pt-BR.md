<div align="center">

# 🐘 pg_upgrade — Ferramenta de Upgrade de Versão Major do PostgreSQL

**Automatize o upgrade de versão major do PostgreSQL sem complicação.**

Um script. Migração completa. Tuning pronto para produção.

[![Shell Script](https://img.shields.io/badge/Shell_Script-bash-green?logo=gnu-bash&logoColor=white)](#)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12%2B-blue?logo=postgresql&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contribuindo)

</div>

---

> **🇺🇸 Read in English:** Full documentation in English available at [`README.md`](README.md).

---

## 🔍 Visão Geral

Atualizar o PostgreSQL para uma nova versão major pode ser complexo e propenso a erros — especialmente em ambientes de produção. O **pg_upgrade** é um script Bash que automatiza todo o processo de ponta a ponta:

1. Instala a versão alvo do PostgreSQL a partir dos repositórios oficiais
2. Cria e configura o novo cluster de dados
3. Aplica tuning de performance no `postgresql.conf` (baseado nas melhores práticas do pg_tune)
4. Executa o `pg_upgrade` para migrar todos os dados de forma transparente
5. Ajusta as portas para que as versões antiga e nova possam coexistir
6. Fornece recomendações de manutenção pós-upgrade

> **Sem etapas manuais. Sem configs esquecidas. Basta executar e atualizar.**

---

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| 🔧 **Instalação Automática** | Instala a nova versão do PostgreSQL a partir do repositório oficial APT |
| 📁 **Setup do Cluster** | Cria diretórios, ajusta permissões e configura o novo cluster |
| ⚡ **Tuning de Performance** | Auto-configura `shared_buffers`, `effective_cache_size`, `max_connections` e mais |
| 🔄 **Migração de Dados** | Executa `pg_upgrade` gerenciando stop/start dos clusters automaticamente |
| 🔌 **Gerenciamento de Portas** | Troca as portas entre versão antiga e nova para transição transparente |
| 🧹 **Pós-Upgrade** | Recomenda execução de `vacuumdb` e atualização de extensões após a migração |

---

## 📋 Requisitos

- **SO:** Debian / Ubuntu (ou qualquer distro que use `apt`)
- **Acesso:** Privilégios root / `sudo`
- **PostgreSQL:** Versão 12 ou superior disponível nos repositórios oficiais

---

## 🚀 Como Usar

```bash
git clone https://github.com/omatheusgit/pg_upgrade.git
cd pg_upgrade
chmod +x upgrade.sh
sudo ./upgrade.sh
```

O script vai solicitar interativamente:

| Parâmetro | Descrição |
|---|---|
| **Versão antiga** | Versão do PostgreSQL atualmente em uso (ex.: `14`) |
| **Versão nova** | Versão alvo do PostgreSQL (ex.: `16`) |
| **Diretório atual** | Caminho do diretório de dados do cluster atual |
| **Diretório novo** | Caminho base onde o novo cluster será criado |

> **💡 Dica:** Siga as instruções na tela com atenção. O script exibe cada etapa sendo executada em tempo real.

---

## ⚙️ Tuning de Performance (pg_tune)

O script aplica automaticamente parâmetros essenciais de tuning no `postgresql.conf` do novo cluster, baseado nas melhores práticas do **pg_tune**:

| Parâmetro | Valor / Regra | Descrição |
|---|---|---|
| `listen_addresses` | `'*'` | Escuta em todas as interfaces (habilita acesso remoto) |
| `shared_buffers` | ≈ 25% da RAM | Memória compartilhada para cache de dados |
| `effective_cache_size` | ≈ 75% da RAM | Estimativa de cache do SO para o query planner |
| `max_connections` | `600` | Máximo de conexões simultâneas |
| `maintenance_work_mem` | `512MB` | Memória para VACUUM, REINDEX e operações similares |
| `idle_in_transaction_session_timeout` | `20000` (ms) | Encerra sessões idle-in-transaction após 20s |
| `deadlock_timeout` | `5s` | Tempo antes de verificar deadlocks |
| `max_locks_per_transaction` | `128` | Máximo de locks por transação |
| `synchronous_commit` | `off` | Commit assíncrono para maior throughput |
| `checkpoint_segments` | `10` | Segmentos WAL antes de forçar checkpoint *(legado)* |

> **📝 Nota:** Revise e ajuste esses valores de acordo com o seu workload e hardware específicos antes de ir para produção.

---

## 🔄 Como Funciona

```
┌──────────────────────────────────────────────────────┐
│  1. Instala nova versão do PostgreSQL (apt)          │
│  2. Cria novo diretório de dados & ajusta permissões │
│  3. Copia pg_hba.conf da versão antiga               │
│  4. Aplica tuning de performance (postgresql.conf)   │
│  5. Para ambos os clusters                           │
│  6. Executa pg_upgrade (migração de dados)           │
│  7. Troca portas (nova → 5432, antiga → 5433)        │
│  8. Reinicia os serviços                             │
│  9. Pós-upgrade: vacuum & atualização de extensões   │
└──────────────────────────────────────────────────────┘
```

---

## ⚠️ Avisos Importantes

> **🛑 SEMPRE faça backup dos seus dados antes de executar este script.**

- ✅ Teste em **ambiente de homologação/dev** primeiro — nunca execute diretamente em produção sem testar
- ✅ Revise os parâmetros do `postgresql.conf` para o seu workload específico
- ✅ Após validação, execute `delete_old_cluster.sh` para remover dados antigos (⚠️ **irreversível**)
- ✅ Execute o comando `vacuumdb` recomendado após o upgrade ser concluído

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

- Abrir uma [Issue](https://github.com/omatheusgit/pg_upgrade/issues) para reportar bugs ou sugerir funcionalidades
- Enviar um [Pull Request](https://github.com/omatheusgit/pg_upgrade/pulls) com melhorias
- Dar uma estrela ⭐ no repo se achou útil!

---

## 📄 Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

---

## 👤 Autor

Criado por **Matheus Rafael** <img src="https://media.giphy.com/media/mKHdmq1QR9Dvq/giphy.gif" alt="Batman GIF" width="60" height="40" />

---

<div align="center">

**Se este projeto te ajudou, dê uma ⭐ no [GitHub](https://github.com/omatheusgit/pg_upgrade)!**

</div>
