# frozen_string_literal: true

require_relative 'lib/ddmemoize/version'

Gem::Specification.new do |spec|
  spec.name          = 'ddmemoize'
  spec.version       = DDMemoize::VERSION
  spec.authors       = ['Denis Defreyne']
  spec.email         = ['denis+rubygems@denis.ws']

  spec.summary       = 'Adds support for memoizing functions'
  spec.homepage      = 'https://github.com/ddfreyne/ddmemoize'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency('ddmetrics', '~> 1.0')
  spec.add_runtime_dependency('ref', '~> 2.0')

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']
end
