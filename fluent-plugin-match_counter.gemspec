# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-match_counter'
  spec.version       = '0.0.2'
  spec.authors       = ['Joshua Mervine']
  spec.email         = ['jmervine@users.noreply.github.com']

  github = "https://github.com/jmervine/fluent-plugin-match_counter"
  spec.metadata = {
    "homepage_uri" => github,
    "documentation_uri" => github,
    "source_code_uri" => github
  }

  spec.summary       = 'FluentD Plugin for counting matched events via a pattern'
  spec.description   = spec.summary
  spec.required_ruby_version = '>= 2.4.0'

  spec.files         = Dir['lib/**/*']
  spec.executables   = []
  spec.test_files    = Dir['test/**/test_*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'test-unit', '~> 3'
  spec.add_development_dependency 'benchmark-ips', ['~> 2.9', '>= 2.9.2']

  spec.add_runtime_dependency 'fluentd', ['>= 0.14.0', '< 2']
end
