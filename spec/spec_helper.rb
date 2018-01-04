# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'ddmemoize'

require 'fuubar'

RSpec.configure do |c|
  c.fuubar_progress_bar_options = {
    format: '%c/%C |<%b>%i| %p%%',
  }
end
