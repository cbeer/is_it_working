# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name = "is_it_working-cbeer"
  gem.version = File.read(File.expand_path('../VERSION', __FILE__))
  gem.summary = %Q{Rack handler for monitoring several parts of a web application.}
  gem.description = %Q{Rack handler for monitoring several parts of a web application so one request can determine which system or dependencies are down.}
  gem.authors = ["Brian Durand", "Chris Beer"]
  gem.email = ["mdobrota@tribune.com", "ddpr@tribune.com", "chris@cbeer.info"]
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.has_rdoc = true
  gem.rdoc_options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  gem.extra_rdoc_files = ["README.rdoc"]

  gem.add_development_dependency('rspec', '>= 2.0')
  gem.add_development_dependency('webmock', '>= 1.6.0')
  gem.add_development_dependency('memcache-client')
  gem.add_development_dependency('dalli')
  gem.add_development_dependency('rails')
end

