# kube_station

Let the ocean meet the tracks...

## Setup

This repo contains the `kube_station` gem located in `./engines/kube_station`.
The root directory of this project is itself a **complete working example** of `kube_station` that can be run locally or deployed.

### Engine only

```
bundle add kube_station
bin/rails kube_station:migrations:install
bin/rails db:migrate
```

### Standalone app

```
git clone https://github.com/general-intelligence-systems/kube_station
cd kube_station
bin/setup
```

## Testing

Docker Compose provides a PostgreSQL test database (port 6432) and a k3s cluster (port 6443). Engine tests run against the real cluster.

```bash
# Start docker services (if not already running)
docker compose up -d

# Run engine tests from within the engine directory
cd engines/kube_station
RAILS_ENV=test bin/rails db:create db:migrate   # first time only
RAILS_ENV=test bin/rails test

# Run a single test file
RAILS_ENV=test bin/rails test test/controllers/kube/station/kinds/resources_controller_test.rb
```
