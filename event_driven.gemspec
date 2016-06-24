# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_driven/version'

Gem::Specification.new do |spec|
  spec.name          = 'event_driven'
  spec.version       = EventDriven::VERSION
  spec.authors       = ['Emerson Huitt']
  spec.email         = ['emerson.huitt@scimedsolutions.com']

  spec.summary       = %q{EventDriven is a port of symfony/event-dispatcher, and provides a set of tools for interacting with events in a system}
  spec.description   = %q{Provides a dispatch system, a basic event class, and a basic listener implementation}
  spec.homepage      = 'https://github.com/emerson-h'

  spec.files         = Dir['{lib}/**/*', 'Rakefile', 'README.md']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
