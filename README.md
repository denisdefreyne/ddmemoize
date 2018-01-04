[![Gem version](https://img.shields.io/gem/v/ddmemoize.svg)](http://rubygems.org/gems/ddmemoize)
[![Gem downloads](https://img.shields.io/gem/dt/ddmemoize.svg)](http://rubygems.org/gems/ddmemoize)
[![Build status](https://img.shields.io/travis/ddfreyne/ddmemoize.svg)](https://travis-ci.org/ddfreyne/ddmemoize)
[![Code Climate](https://img.shields.io/codeclimate/github/ddfreyne/ddmemoize.svg)](https://codeclimate.com/github/ddfreyne/ddmemoize)
[![Code Coverage](https://img.shields.io/codecov/c/github/ddfreyne/ddmemoize.svg)](https://codecov.io/gh/ddfreyne/ddmemoize)

# DDMemoize

_DDMemoize_ adds support for memoizing Ruby functions.

For example, the following Fibonacci implementation runs quickly (in O(n) rather than in O(2^n)):

```ruby
class FibFast
  DDMemoize.activate(self)

  memoized def run(n)
    if n == 0
      0
    elsif n == 1
      1
    else
      run(n - 1) + run(n - 2)
    end
  end
end
```

Features:

* Supports memoizing functions on frozen objects
* Releases memoized values when needed in order to reduce memory pressure
* Optionally records metrics

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ddmemoize'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ddmemoize

## Usage

First, require `ddmemoize` and enable it using `DDMemoize.activate`:

```ruby
require 'ddmemoize'

class FibFast
  DDMemoize.activate(self)

  # …
end
```

To memoize a function, call `memoize` with the name of the function:

```ruby
  def run(n)
    # …
  end
  memoize :run
```

Alternatively, prepend `memoized` to the function definition:

```ruby
  memoized def run(n)
    # …
  end
```

Do not memoize functions that depend on mutable state.

### Metrics

To activate metrics, call `DDMemoize.enable_metrics` after requiring `ddmemoize`.

To print the collected metrics, call `DDMemoize.print_metrics`:

```ruby
DDMemoize.print_metrics
```

```
memoization │ hit   miss       %
────────────┼───────────────────
FibFast#fib │ 998   1001   49.9%
```

## Development

Install dependencies:

    $ bundle

Run tests:

    $ bundle exec rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddfreyne/ddmemoize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DDMemoize project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ddfreyne/ddmemoize/blob/master/CODE_OF_CONDUCT.md).
