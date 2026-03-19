# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2025-05-01

### Added
- Initial release of the pg_upgrade automation script
- Automatic installation of target PostgreSQL version from official APT repositories
- New cluster directory creation with proper permissions
- Performance tuning based on pg_tune best practices:
  - `shared_buffers` (≈25% RAM)
  - `effective_cache_size` (≈75% RAM)
  - `max_connections`, `maintenance_work_mem`, `deadlock_timeout`, and more
- Data migration via `pg_upgrade` with automatic cluster stop/start
- Port swap between old and new PostgreSQL versions
- Copy of `pg_hba.conf` from old version to maintain host access rules
- Post-upgrade recommendations (vacuumdb, extension updates)
- Interactive prompts with colored terminal output
- Cluster health check — auto-creates cluster if not online
