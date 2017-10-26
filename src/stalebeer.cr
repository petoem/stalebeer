require "./stalebeer/*"

module StaleBeer
  class Cache(K, V)
    @cache = Hash(K, Beer(V)).new

    def initialize(@default_cache_time : Time::Span = 10.minutes)
      @waiter_channel = Channel(K).new
      @waiter = Waiter(K, V).new self, @waiter_channel
      spawn do
        loop { @cache.delete @waiter_channel.receive }
      end
    end
    
    def [](key : K) : V?
      get key
    end

    def get(key : K) : V?
      @cache[key]?.try &.value
    end

    def []=(key : K, value : V)
      set key, value, @default_cache_time
    end

    def []=(key : K, expiration : Time::Span, value : V)
      set key, value, expiration
    end

    def set(key : K, value : V, expiration : Time::Span = @default_cache_time)
      @cache[key] = Beer(V).new value, expiration
      nil
    end

    def refresh(key : K, time : Time::Span = @default_cache_time) : Bool
      if beer = @cache[key]?
        @cache[key] = beer.refresh time
        true
      else
        false
      end
    end

    def expires(key : K) : Time::Span?
      @cache[key]?.try &.time_span
    end

    def purge : Nil
      @cache.clear
      nil
    end

    protected def values : Array(Beer(V))
      @cache.values
    end

    def keys : Array(K)
      @cache.keys
    end

    protected def raw : Hash(K,Beer(V))
      @cache
    end

    private class Waiter(K, V)
      @waiter : Concurrent::Future(Nil)
      @last_clean : Time
  
      def initialize(@cache : Cache(K, V), @channel : Channel(K))
        @last_clean = Time.now
        @waiter = delay 0.1, &->clean
      end

      private def clean
        last_clean, @last_clean = @last_clean, Time.now
        last_clean = @last_clean - last_clean
        @waiter = delay 0.1, &->clean
        @cache.raw.each do |key, beer|
          @cache.raw[key] = beer.stand last_clean
          @channel.send key if @cache.raw[key].time_span <= 0.seconds
        end
        nil
      end
    end
  end

  private struct Beer(V)
    getter value : V
    getter time_span : Time::Span

    def initialize(@value : V, @time_span : Time::Span); end

    def refresh(@time_span : Time::Span) : Beer(V)
      self
    end

    def stand(for time : Time::Span) : Beer(V)
      @time_span = @time_span - time
      self
    end
  end
end
