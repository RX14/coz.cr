# coz.cr

[Coz](https://github.com/plasma-umass/coz) profiling for Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     coz:
       github: RX14/coz.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "coz"

# Progress point
Coz.progress

# Named progress point
Coz.progress("foo")

# Latency profiling
Coz.begin("foo")
foo(...)
Coz.end("foo")

# Latency profiling with block
Coz.latency("foo") { foo(...) }
```

Run as usual with `coz run --- ./executable`

## Contributing

1. Fork it (<https://github.com/RX14/coz.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [RX14](https://github.com/RX14) - creator and maintainer
