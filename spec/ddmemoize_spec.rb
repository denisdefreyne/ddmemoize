# frozen_string_literal: true

describe DDMemoize do
  it 'has a version number' do
    expect(DDMemoize::VERSION).not_to be nil
  end

  class MemoizationSpecSample1
    DDMemoize.activate(self)

    def initialize(value)
      @value = value
    end

    def run(n)
      @value * 10 + n
    end
    memoize :run
  end

  class MemoizationSpecSample2
    DDMemoize.activate(self)

    def initialize(value)
      @value = value
    end

    def run(n)
      @value * 100 + n
    end
    memoize :run
  end

  class MemoizationSpecUpcaser
    DDMemoize.activate(self)

    def run(value)
      value.upcase
    end
    memoize :run
  end

  class MemoizationSpecEqual
    TELEMETRY = ::DDTelemetry.new
    DDMemoize.activate(self, telemetry: TELEMETRY)

    class EqualToEverythingValue
      def equal?(*)
        true
      end
    end

    def run
      EqualToEverythingValue.new
    end
    memoize :run
  end

  class MemoizationSpecUpcaserInlineSyntax
    DDMemoize.activate(self)

    memoized def run(value)
      value.upcase
    end
  end

  class MemoizationSpecInlineSyntaxReturn
    DDMemoize.activate(self)

    class << self
      attr_reader :sym
    end

    def self.record(sym)
      @sym = sym
    end

    record memoized def run; end
  end

  class MemoizationSpecWithTelemetry
    TELEMETRY = ::DDTelemetry.new
    DDMemoize.activate(self, telemetry: TELEMETRY)

    def run(value)
      value.upcase
    end
    memoize :run
  end

  example do
    sample1a = MemoizationSpecSample1.new(10)
    sample1b = MemoizationSpecSample1.new(15)
    sample2a = MemoizationSpecSample2.new(20)
    sample2b = MemoizationSpecSample2.new(25)

    3.times do
      expect(sample1a.run(5)).to eq(10 * 10 + 5)
      expect(sample1b.run(7)).to eq(10 * 15 + 7)
      expect(sample2a.run(5)).to eq(100 * 20 + 5)
      expect(sample2b.run(7)).to eq(100 * 25 + 7)
    end
  end

  it 'supports frozen objects' do
    sample = MemoizationSpecSample1.new(10)
    sample.freeze
    sample.run(5)
  end

  it 'supports objects that bizarrely override #equal?' do
    sample = MemoizationSpecEqual.new
    sample.freeze
    sample.run
    sample.run
    sample.run

    telemetry = MemoizationSpecEqual::TELEMETRY
    counter = telemetry.counter(:memoization)

    expect(counter.value(['MemoizationSpecEqual#run', :miss])).to eq(1)
    expect(counter.value(['MemoizationSpecEqual#run', :hit])).to eq(2)
  end

  it 'supports memoized def … syntax' do
    upcaser = MemoizationSpecUpcaserInlineSyntax.new
    expect(upcaser.run('hi')).to eq('HI')
  end

  it 'does not crash on #inspect' do
    upcaser = MemoizationSpecUpcaser.new
    10_000.times do |i|
      upcaser.run("hello world #{i}")
    end

    GC.start
    GC.start

    upcaser.inspect
  end

  it 'returns method name' do
    expect(MemoizationSpecInlineSyntaxReturn.sym).to eq(:run)
  end

  it 'records telemetry' do
    sample = MemoizationSpecWithTelemetry.new

    sample.run('denis')
    sample.run('denis')
    sample.run('defreyne')

    telemetry = MemoizationSpecWithTelemetry::TELEMETRY
    counter = telemetry.counter(:memoization)

    expect(counter.value(['MemoizationSpecWithTelemetry#run', :miss])).to eq(2)
    expect(counter.value(['MemoizationSpecWithTelemetry#run', :hit])).to eq(1)
  end

  it 'prints recorded telemetry' do
    sample = MemoizationSpecWithTelemetry.new

    sample.run('denis')
    sample.run('denis')
    sample.run('defreyne')

    expected = <<~OUTPUT
                           memoization │ hit   miss       %
      ─────────────────────────────────┼───────────────────
      MemoizationSpecWithTelemetry#run │   2      4   33.3%
    OUTPUT

    telemetry = MemoizationSpecWithTelemetry::TELEMETRY
    expect { DDMemoize.print_telemetry(telemetry) }.to output(expected).to_stdout
  end
end
