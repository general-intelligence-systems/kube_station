# frozen_string_literal: true

# Preload the Rails application before forking worker processes.
# This reduces memory usage via copy-on-write and speeds up worker startup.
require_relative "config/environment"
