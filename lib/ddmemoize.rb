# frozen_string_literal: true

require 'ref'
require 'ddtelemetry'
require 'singleton'

require_relative 'ddmemoize/version'

module DDMemoize
  class Value
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  # @api private
  class TelemetryMap
    include Singleton

    def initialize
      @map = {}
    end

    def [](mod)
      @map[mod]
    end

    def []=(mod, telemetry)
      @map[mod] = telemetry
    end
  end

  NONE = Object.new

  def self.activate(mod, telemetry: nil)
    mod.extend(Mixin)
    TelemetryMap.instance[mod] = telemetry
  end

  def self.telemetry_for(mod)
    TelemetryMap.instance[mod]
  end

  def self.print_telemetry(telemetry)
    headers = %w[memoization hit miss %]

    rows_raw = telemetry.counter(:memoization).map do |(name, type), counter|
      { name: name, type: type, count: counter.value }
    end

    rows = rows_raw.group_by { |r| r[:name] }.map do |name, rows_for_name|
      rows_by_type = rows_for_name.group_by { |r| r[:type] }

      num_hit = rows_by_type.fetch(:hit, []).fetch(0, {}).fetch(:count, 0)
      num_miss = rows_by_type.fetch(:miss, []).fetch(0, {}).fetch(:count, 0)
      pct = num_hit.to_f / (num_hit + num_miss).to_f

      [name, num_hit.to_s, num_miss.to_s, "#{format('%3.1f', pct * 100)}%"]
    end

    all_rows = [headers] + rows
    puts DDTelemetry::Table.new(all_rows).to_s
  end

  module Mixin
    def memoize(method_name)
      original_method_name = '__nonmemoized_' + method_name.to_s
      alias_method original_method_name, method_name

      instance_cache = Hash.new { |hash, key| hash[key] = {} }
      telemetry = DDMemoize.telemetry_for(self)

      define_method(method_name) do |*args|
        instance_method_cache = instance_cache[self]

        value = NONE
        if instance_method_cache.key?(args)
          object = instance_method_cache[args].object
          value = object ? object.value : NONE
        end

        if telemetry
          counter_label = is_a?(Class) ? "#{self}.#{method_name}" : "#{self.class}##{method_name}"

          if NONE.equal?(value)
            telemetry.counter(:memoization).increment([counter_label, :miss])
          else
            telemetry.counter(:memoization).increment([counter_label, :hit])
          end
        end

        if value.equal?(NONE)
          send(original_method_name, *args).tap do |r|
            instance_method_cache[args] = Ref::SoftReference.new(Value.new(r))
          end
        else
          value
        end
      end
    end
    alias memoized memoize
  end
end
