require_relative 'lib/circuit_switch/version'

Gem::Specification.new do |spec|
  spec.name          = "circuit_switch"
  spec.version       = CircuitSwitch::VERSION
  spec.authors       = ["makicamel"]
  spec.email         = ["unright@gmail.com"]

  spec.summary       = 'Circuit switch with report tools'
  spec.description   = "circuit_switch is a gem for 'difficult' application. This switch helps to make changes easier and deploy safely."
  spec.homepage      = 'https://github.com/makicamel/circuit_switch'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/makicamel/circuit_switch'
  spec.metadata["changelog_uri"] = 'https://github.com/makicamel/circuit_switch/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'activejob'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'redis', '~> 4.6'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'test-unit-rr'
end
