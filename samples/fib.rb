# frozen_string_literal: true

require 'ddmemoize'

DDMemoize.enable_metrics

class FibFast
  DDMemoize.activate(self)

  memoized def fib(n)
    case n
    when 0
      0
    when 1
      1
    else
      fib(n - 1) + fib(n - 2)
    end
  end
end

p FibFast.new.fib(1000)

DDMemoize.print_metrics
