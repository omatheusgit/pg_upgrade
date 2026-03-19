<div align="center">

# 🐘 pg_upgrade — PostgreSQL Major Version Upgrade Tool

**Automate your PostgreSQL major version upgrades with zero hassle.**

One script. Full migration. Production-ready tuning.

[![Shell Script](https://img.shields.io/badge/Shell_Script-bash-green?logo=gnu-bash&logoColor=white)](#)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12%2B-blue?logo=postgresql&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

</div>

---

> **🇧🇷 Leia em Português:**  Documentação completa em português disponível em [`README_pt-BR.md`](README_pt-BR.md).

---

## 🔍 Overview

Upgrading PostgreSQL to a new major version can be complex and error-prone — especially in production environments. **pg_upgrade** is a single Bash script that automates the entire process end-to-end:

1. Installs the target PostgreSQL version from official repositories
2. Creates and configures the new data cluster
3. Applies performance tuning to `postgresql.conf` (based on pg_tune best practices)
4. Runs `pg_upgrade` to migrate all data seamlessly
5. Adjusts ports so old and new versions can coexist
6. Provides post-upgrade maintenance recommendations

> **No manual steps. No forgotten configs. Just run and upgrade.**

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔧 **Auto Install** | Installs the new PostgreSQL version from the official APT repository |
| 📁 **Cluster Setup** | Creates directories, sets permissions, and configures the new cluster |
| ⚡ **Performance Tuning** | Auto-tunes `shared_buffers`, `effective_cache_size`, `max_connections`, and more |
| 🔄 **Data Migration** | Runs `pg_upgrade` handling cluster stop/start automatically |
| 🔌 **Port Management** | Swaps ports between old and new versions for seamless transition |
| 🧹 **Post-Upgrade** | Recommends `vacuumdb` and extension updates after migration |

---

## 📋 Requirements

- **OS:** Debian / Ubuntu (or any distro using `apt`)
- **Access:** Root / `sudo` privileges
- **PostgreSQL:** Version 12 or higher available in official repositories

---

## 🚀 Quick Start

```bash
git clone https://github.com/omatheusgit/pg_upgrade.git
cd pg_upgrade
chmod +x upgrade.sh
sudo ./upgrade.sh
```

The script will interactively ask for:

| Parameter | Description |
|---|---|
| **Old version** | The PostgreSQL version currently running (e.g., `14`) |
| **New version** | The target PostgreSQL version (e.g., `16`) |
| **Current data dir** | Path to the existing cluster data directory |
| **New data dir** | Base path where the new cluster will be created |

> **💡 Tip:** Follow the on-screen instructions carefully. The script shows every step being executed in real time.

---

## ⚙️ Performance Tuning (pg_tune)

The script automatically applies essential tuning parameters to the new cluster's `postgresql.conf`, based on **pg_tune** best practices:

| Parameter | Value / Rule | Description |
|---|---|---|
| `listen_addresses` | `'*'` | Listen on all interfaces (enable remote access) |
| `shared_buffers` | ≈ 25% of RAM | Shared memory for caching data |
| `effective_cache_size` | ≈ 75% of RAM | OS cache estimation for the query planner |
| `max_connections` | `600` | Maximum simultaneous connections |
| `maintenance_work_mem` | `512MB` | Memory for VACUUM, REINDEX, and similar ops |
| `idle_in_transaction_session_timeout` | `20000` (ms) | Kill idle-in-transaction sessions after 20s |
| `deadlock_timeout` | `5s` | Time before checking for deadlocks |
| `max_locks_per_transaction` | `128` | Max locks per transaction |
| `synchronous_commit` | `off` | Async commit for higher throughput |
| `checkpoint_segments` | `10` | WAL segments before forced checkpoint *(legacy)* |

> **📝 Note:** Review and adjust these values based on your specific workload and hardware before going to production.

---

## 🔄 How It Works

```
┌─────────────────────────────────────────────────┐
│  1. Install new PostgreSQL version (apt)        │
│  2. Create new data directory & set permissions │
│  3. Copy pg_hba.conf from old version           │
│  4. Apply performance tuning (postgresql.conf)  │
│  5. Stop both clusters                          │
│  6. Run pg_upgrade (data migration)             │
│  7. Swap ports (new → 5432, old → 5433)         │
│  8. Restart services                            │
│  9. Post-upgrade: vacuum & extension updates    │
└─────────────────────────────────────────────────┘
```

---

## ⚠️ Important Warnings

> **🛑 ALWAYS back up your data before running this script.**

- ✅ Test in a **staging/dev environment** first — never run directly in production without testing
- ✅ Review the `postgresql.conf` parameters for your specific workload
- ✅ After validation, run `delete_old_cluster.sh` to remove old data (⚠️ **irreversible**)
- ✅ Run the recommended `vacuumdb` command after the upgrade completes

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Open an [Issue](https://github.com/omatheusgit/pg_upgrade/issues) to report bugs or suggest features
- Submit a [Pull Request](https://github.com/omatheusgit/pg_upgrade/pulls) with improvements
- Star ⭐ the repo if you find it useful!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

Created by **Matheus Rafael** <img src="https://media.giphy.com/media/mKHdmq1QR9Dvq/giphy.gif" alt="Batman GIF" width="60" height="40" />

---

<div align="center">

**If this project helped you, give it a ⭐ on [GitHub](https://github.com/omatheusgit/pg_upgrade)!**

</div>



