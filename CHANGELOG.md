# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-04-02

### Added

- Valkey database creation on OVHcloud Public Cloud
- Multi-node support (minimum 2 for high availability)
- Optional private network attachment (`network_id`, `subnet_id`)
- Optional IP access restrictions
- Optional backup configuration with time and region
- Optional advanced Valkey configuration (Redis-compatible)
- User management with ACL (categories, channels, commands, keys)
- Deletion protection enabled by default
- Input validations (version format, plan, backup time, disk size, user uniqueness)
- Native Terraform tests (`terraform test`)
- Examples: basic and complete
