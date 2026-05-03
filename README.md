# kube_station

Let the ocean meet the tracks...

## Setup

This project contains the `kube_station` located in `./engines/kube_station`.
The root directory of this project is itself a complete working example of `kube_station` that can be run locally or deployed.

### Engine only

```
bundle add kube_station
bin/rails kube_station:migrations:install
bin/rails db:migrate
```

### Standalone

```
git clone https://github.com/general-intelligence-systems/kube_station
cd kube_station
bin/setup
```
