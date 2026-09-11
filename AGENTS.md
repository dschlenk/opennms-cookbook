# OpenNMS Cookbook - Agent Guide

Chef cookbook for OpenNMS Horizon 33 on EL9 (RHEL/Rocky/Oracle). Cinc/Chef >=18.5, Ruby 3.0.1.

## Commands
- Style: `cookstyle` (CI runs cookstyle)
- Markdown: `cinc exec mdl documentation/*.md`
- Test suite: `kitchen verify default` (CI default)
- Single suite: `kitchen verify <suite-name>` e.g. `kitchen verify recommended`
- Kitchen config in `kitchen.yml`, uses dokken driver with `cincproject/cinc` image. Platforms: oraclelinux-9
- CI pipeline: docker login → install cinc-workstation 25 → `cinc shell-init bash` → `cinc exec bundle install` → mdl → cookstyle → `kitchen verify default`

## Architecture
- Cookbook version matches Horizon major: 33.x supports Horizon 33.x on EL9
- Entry recipes:
  - `opennms::default` installs OpenNMS from official yum repos, runs `runjava -s` if java.conf missing, runs `install -dis` if not configured
  - `opennms::postgres` installs PostgreSQL 15 via PGDG
  - `opennms::rrdtool` switches timeseries to RRDTool
  - `opennms::kafka_producer` enables Kafka producer
- Attributes in `attributes/default.rb`. Key defaults:
  - `node['opennms']['version'] = '33.1.8-1'`
  - `node['opennms']['conf']['env']['START_TIMEOUT'] = 30` (kitchen overrides to 60)
  - `node['opennms']['upgrade'] = false`
  - `node['opennms']['templates'] = true`
  - `node['opennms']['jre_path']` optional
- Templates live in `templates/`; cookbook can be overridden via `node['opennms']['default_template_cookbook']` and per-template `...['cookbook']` attributes
- Custom resources documented in `documentation/README.md` and `documentation/*.md`. Uses OpenNMS REST API; OpenNMS must be running to converge provisioning resources
- Vault requirements:
  - Postgres creds: vault `node['opennms']['postgresql']['user_vault']` item `node['opennms']['postgresql']['user_vault_item']` with `postgres` and `opennms` passwords
  - Admin password: vault `node['opennms']['users']['admin']['vault']` item `node['opennms']['users']['admin']['vault_item']` with `password`
  - SCV password: vault `node['opennms']['scv']['vault']` item `scv` with `password`

## Conventions
- Chef dependencies: `postgresql` cookbook from sous-chefs, compatible Java runtime required
- Upgrade handling: set `node['opennms']['upgrade'] = true` to enable automatic rpmnew/rpmsave cleanup via `libraries/upgrade.rb`
- `node['opennms']['conf']['env']` for opennms.conf env vars; `node['opennms']['properties']['files']` for `opennms.properties.d/*`
- `node['opennms']['features_boot']['files']` for `$OPENNMS_HOME/etc/featuresBoot.d/*.boot`
- Policyfile used in tests: `Policyfile.rb` with fixture cookbooks under `test/fixtures/cookbooks/`
- Style config: `.rubocop.yml` inherits `.rubocop_todo.yml`; `.ruby-version` 3.0.1
- CHANGELOG.md tracks releases

## Testing
- Integration tests: InSpec under `test/integration/<suite>/controls/`
- Suites defined in `kitchen.yml`; many suites for custom resources (e.g., `event`, `policy`, `collection_package`, etc.)
- Test fixtures: `test/fixtures/cookbooks/openjdk17`, `opennms_resource_tests`
- Running a single test suite requires dokken/docker; CI uses ubuntu-2404 with docker
