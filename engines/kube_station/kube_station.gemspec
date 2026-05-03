require_relative "lib/kube/station/version"

Gem::Specification.new do |spec|
  spec.name        = "kube_station"
  spec.version     = Kube::Station::VERSION
  spec.authors     = [ "Nathan Kidd" ]
  spec.email       = [ "nathankidd@hey.com" ]
  spec.homepage    = "https://github.com/general-intelligence-systems/kube_station"
  spec.summary     = "Kubernetes on rails..."
  spec.description = spec.summary

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3"
  spec.add_dependency "kube_cluster", "~> 0.4.11"
  spec.add_dependency "rails-active-ui", "~> 0.3"
end
