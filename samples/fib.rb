# frozen_string_literal: true

require 'ddmemoize'

TELEMETRY = DDTelemetry.new

class FibFast
  DDMemoize.activate(self, telemetry: TELEMETRY)

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

DDMemoize.print_telemetry(TELEMETRY)
