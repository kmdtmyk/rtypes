require_relative "lib/types_generator/version"

Gem::Specification.new do |spec|
  spec.name        = "types_generator"
  spec.version     = TypesGenerator::VERSION
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = "https://github.com/kmdtmyk/types_generator"
  spec.summary     = "Summary of TypesGenerator."
  # spec.description = "TODO: Description of TypesGenerator."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  if ENV['RAILS_VERSION']
    spec.add_dependency "rails", "~> #{ENV['RAILS_VERSION']}"
  else
    spec.add_dependency "rails"
  end

  spec.add_development_dependency 'sqlite3', '~> 1.4'

end
