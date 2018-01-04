# frozen_string_literal: true

require 'ref'
require 'ddmetrics'
require 'singleton'

require_relative 'ddmemoize/version'

module DDMemoize
  class Value
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  NONE = Object.new

  def self.activate(mod)
    mod.extend(Mixin)
  end

  class << self
    def enable_metrics
      @metrics_enabled = true
    end

    def metrics_enabled?
      @metrics_enabled
    end

    def metrics_counter
      @_metrics_counter ||= DDMetrics::Counter.new
    end
  end

  def self.print_metrics
    headers = %w[memoization hit miss %]

    rows_raw = DDMemoize.metrics_counter.map do |label, count|
      {
        name: label.fetch(:method),
        type: label.fetch(:type),
        count: count,
      }
    end

    rows = rows_raw.group_by { |r| r[:name] }.map do |name, rows_for_name|
      rows_by_type = rows_for_name.group_by { |r| r[:type] }

      num_hit = rows_by_type.fetch(:hit, []).fetch(0, {}).fetch(:count, 0)
      num_miss = rows_by_type.fetch(:miss, []).fetch(0, {}).fetch(:count, 0)
      pct = num_hit.to_f / (num_hit + num_miss).to_f

      [name, num_hit.to_s, num_miss.to_s, "#{format('%3.1f', pct * 100)}%"]
    end

    all_rows = [headers] + rows
    puts DDMetrics::Table.new(all_rows).to_s
  end

  module Mixin
    def memoize(method_name)
      original_method_name = '__nonmemoized_' + method_name.to_s
      alias_method original_method_name, method_name

      instance_cache = Hash.new { |hash, key| hash[key] = {} }
      full_method_name = "#{self}##{method_name}"

      define_method(method_name) do |*args|
        instance_method_cache = instance_cache[self]

        value = NONE
        if instance_method_cache.key?(args)
          object = instance_method_cache[args].object
          value = object ? object.value : NONE
        end

        if DDMemoize.metrics_enabled?
          if NONE.equal?(value)
            DDMemoize.metrics_counter.increment(method: full_method_name, type: :miss)
          else
            DDMemoize.metrics_counter.increment(method: full_method_name, type: :hit)
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
