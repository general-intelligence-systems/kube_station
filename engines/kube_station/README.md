# Kube::Station
Kubernetes on Rails...

## Installation

Add to your application's Gemfile:

```ruby
gem "kube_station", path: "engines/kube_station"
```

Install migrations and run them:

```bash
bin/rails kube_station:install:migrations
bin/rails db:migrate
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
