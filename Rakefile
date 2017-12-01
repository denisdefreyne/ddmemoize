# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

RuboCop::RakeTask.new(:rubocop)

task default: :test

task test: %i[spec rubocop]
