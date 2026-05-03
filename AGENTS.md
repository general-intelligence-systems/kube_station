# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Start dev server (starts docker compose + Falcon on localhost:3000)
bin/dev

# Database
bin/rails db:create db:migrate
bin/rails db:seed            # creates default Config, Cluster, and 3 approved resources

# Run all engine tests
bin/rails test engines/kube_station/test/

# Run a single test file
bin/rails test engines/kube_station/test/kube_test.rb

# Rails console
bin/rails console

# Docker services (PostgreSQL on 5432, k3s on 6443)
docker compose up -d
```

## Architecture

- **Host app** at project root — Rails 8.1.3, PostgreSQL, Falcon web server, Propshaft asset pipeline, Hotwire (Turbo + Stimulus), importmap-rails
- **Engine** at `engines/kube_station/` — isolated namespace `Kube::Station`, contains all models, controllers, views, and routes

## Key Gems

- `kube_cluster` — Kubernetes cluster connectivity. Requires `scampi/kernel_ext` to be loaded first (for inline test blocks). Loaded at engine class body in `lib/kube/station/engine.rb`.
- `rails-active-ui` — Fomantic-UI component system. Views use `.html.ruby` files (not ERB). Components are PascalCase method calls (`Header()`, `Table()`, `Button()`, etc.).
- `kube_kubectl` — kubectl CLI wrapper via string builder DSL. Usage: `ctl.run("get pods -o json")`

## Models (Kube::Station::)

- `Config` — stores kubeconfig YAML in jsonb `data` field. Has `with_kubeconfig_file` that yields a tempfile path.
- `Cluster` — belongs_to config, has_many resources. Has `with_connection` (yields `Kube::Cluster::Instance`) and `list_resources(kind)`.
- `Resource` — belongs_to cluster. Has `kind` (string). Represents **approved** k8s resource kinds. Unique index on [kind, cluster_id].

## Controllers

- `ResourcesController` — CRUD for approved resource kinds (index, new, create, destroy)
- `Resources::ItemsController` — lists live k8s resources for an approved kind

## Routes

Engine mounted at `/kube`. Routes:
- `GET /kube/resources` — list approved kinds
- `GET /kube/resources/new` — modal form to add a kind
- `POST /kube/resources` — create
- `DELETE /kube/resources/:id` — remove
- `GET /kube/resources/:resource_id/items` — list live k8s resources

## Views (rails-active-ui)

- Views use `.html.ruby` extension, not `.erb`
- Components: `Table()`, `Menu()`, `MenuItem()`, `Header()`, `Button()`, `ButtonTo()`, `Form()`, `Message()`, `LinkTo()`, `BackButton()`, `TurboFrame()`, `Modal()`, etc.
- `ButtonTo` takes keyword args only: `ButtonTo(url:, method:, color:, confirm:) { text "label" }`
- Forms open in modals via `TurboFrame(id: "modal")` + `Modal(turbo: true, blurring: true)` in layout
- Layout at `engines/kube_station/app/views/layouts/kube/station/application.html.ruby`
- Fomantic-UI CSS loaded via `StylesheetLink("stylesheets.css")`
- jQuery + Fomantic JS loaded via `fui_javascript_tags` helper
- Stimulus controllers registered via `registerFuiControllers(application)` in `app/javascript/controllers/index.js`

## Engine Setup Notes

The engine (`lib/kube/station/engine.rb`) has two important pieces:
1. `require "scampi/kernel_ext"` then `require "kube/cluster"` at class body (not in initializer — avoids Zeitwerk conflicts)
2. Asset initializer that adds rails-active-ui's `app/assets` to Propshaft paths (the gem's own engine doesn't register this path)

## Namespace Collision

When referencing the kube_cluster gem's `Kube::Cluster` module from within `Kube::Station::Cluster` model, use `::Kube::Cluster` to avoid resolving to the model itself.

## Seeds

`db/seeds.rb` creates a default Config (from `kubeconfig.yaml`), default Cluster, and three approved resources: Pod, Deployment, ConfigMap.

## Docker Services

`docker-compose.yml` provides:
- `db` — PostgreSQL 16 on port 5432 (development)
- `db_test` — PostgreSQL 16 on port 6432 (test, tmpfs-backed)
- `cluster` — k3s (Kubernetes) on port 6443, outputs `kubeconfig.yaml` to project root
