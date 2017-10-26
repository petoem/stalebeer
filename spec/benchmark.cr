require "./spec_helper"
require "benchmark"

cache = StaleBeer::Cache(Float64, Float64).new
# Add ~100_000 key/value pairs to cache.
100_000.times do |i|
  cache.set rand, rand
end

puts "#{cache.keys.size} key/value pairs in cache."

# Take a random key to test
key = cache.keys[rand(cache.keys.size)]

Benchmark.ips do |x|
  x.report("get key") { cache.get key }
  x.report("get [key]") { cache[key] }
  x.report("refresh") { cache.refresh key }  
  x.report("refresh with Time::Span") { cache.refresh key, 20.minutes }
  x.report("expires") { cache.expires key }
  x.report("benchmark generation") { rand }
  x.report("benchmark key/value generation") { rand; rand }
  x.report("set key, value with literal") { cache.set 0.5, 0.7 }
  x.report("set key, value") { cache.set rand, rand }
  x.report("set key, value with Time::Span") { cache.set rand, rand, 10.hours }
end
