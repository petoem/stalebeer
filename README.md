<p align="center">
  <img width="225" src="https://cdn.rawgit.com/twitter/twemoji/gh-pages/svg/1f37a.svg">
  <h2 align="center">StaleBeer</h2>
  <p align="center">Yet another key/value cache where pairs can expire<p>
  <p align="center">
    <a href="https://travis-ci.org/petoem/stalebeer"><img src="https://img.shields.io/travis/petoem/stalebeer.svg?style=flat-square"></a>
    <a href="https://github.com/petoem/stalebeer/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square"></a>
    <a href="https://github.com/petoem/stalebeer/releases"><img src="https://img.shields.io/github/release/petoem/stalebeer.svg?style=flat-square"></a>
  </p>
</p>

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stalebeer:
    github: petoem/stalebeer
```

## Usage

```crystal
require "stalebeer"

cache = StaleBeer::Cache(String, Int32).new

cache.set "Zwickelbier", 250
cache.get "Zwickelbier" # => 250

cache.set "Dunkelbier", 300, 2.seconds
sleep 3
cache.get "Dunkelbier" # => nil
```

## API

```crystal
# Define types for key/values pairs
StaleBeer::Cache(K, V)

# Creates a new instance and sets the time after which key/value pairs expire
.new(@default_cache_time : Time::Span = 10.minutes)

# Returns the value for the key or `nil` if the key does not exist or is expired
.get(key : K) : V?

# Adds the key/value pair to the cache and sets the time it should live
.set(key : K, value : V, expiration : Time::Span = @default_cache_time)

# Resets the time to the given one and returns `true` if successful 
.refresh(key : K, time : Time::Span = @default_cache_time) : Bool

# Returns the remaining time the key has left
.expires(key : K) : Time::Span?

# Deletes all key/value pairs from the cache
.purge : Nil

# Returns an array of all keys in cache
.keys : Array(K)
```

## Contributing

1. Fork it ( https://github.com/petoem/stalebeer/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [petoem](https://github.com/petoem) Michael Petö - creator, maintainer

## License

Code licensed under the MIT [License](https://github.com/petoem/stalebeer/blob/master/LICENSE)

Beer image from [Twitter Emoji (Twemoji)](https://github.com/twitter/twemoji)
