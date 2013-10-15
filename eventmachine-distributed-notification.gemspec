# -*- encoding: utf-8 -*-
require File.expand_path('../lib/eventmachine-distributed-notification/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["youpy"]
  gem.email         = ["youpy@buycheapviagraonlinenow.com"]
  gem.description   = "An EventMachine extension to watch OSX's Distributed Notification, posted by iTunes etc."
  gem.summary       = "An EventMachine extension to watch OSX's Distributed Notification"
  gem.homepage      = "http://github.com/youpy/eventmachine-distributed-notification"

  gem.extensions    = ["ext/observer_native/extconf.rb", "ext/poster_native/extconf.rb"]
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "eventmachine-distributed-notification"
  gem.require_paths = ["lib"]
  gem.version       = EventMachine::DistributedNotification::VERSION
  gem.licenses      = ["MIT"]

  gem.add_dependency('eventmachine')
  gem.add_development_dependency('rspec', ['~> 2.8.0'])
  gem.add_development_dependency('rake')
  gem.add_development_dependency('itunes-client')
end
