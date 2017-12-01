# frozen_string_literal: true

require 'ref'

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

  module Mixin
    def memoize(method_name)
      original_method_name = '__nonmemoized_' + method_name.to_s
      alias_method original_method_name, method_name

      instance_cache = Hash.new { |hash, key| hash[key] = {} }

      define_method(method_name) do |*args|
        instance_method_cache = instance_cache[self]

        value = NONE
        if instance_method_cache.key?(args)
          object = instance_method_cache[args].object
          value = object ? object.value : NONE
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
