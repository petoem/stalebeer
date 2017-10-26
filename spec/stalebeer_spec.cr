require "./spec_helper"

describe StaleBeer do
  it "save key value pairs" do
    cache = StaleBeer::Cache(String, String).new
    cache.set "beer_1", "Zwickelbier"
    cache["beer_2"] = "Kellerbier"
    cache.set "beer_3", "Lager"
    cache.get("beer_1").should eq("Zwickelbier")
    cache["beer_2"].should eq("Kellerbier")
    cache.get("beer_3").should eq("Lager")
  end

  it "allow different value types" do
    cache = StaleBeer::Cache(Int32, String).new
    cache.set 1, "Zwickelbier"
    cache.set 2, "Kellerbier"
    cache.set 3, "Lager"
    cache.get(1).should eq("Zwickelbier")
    cache.get(2).should eq("Kellerbier")
    cache.get(3).should eq("Lager")

    cache_2 = StaleBeer::Cache(String, Int32 | String | Float64).new
    cache_2.set "key_1", 250
    cache_2.set "key_2", "dunkles"
    cache_2.set "key_3", 0.5_f64
    cache_2.get("key_1").should eq(250)
    cache_2.get("key_2").should eq("dunkles")
    cache_2.get("key_3").should eq(0.5_f64)
  end

  it "key value pairs expire" do
    cache = StaleBeer::Cache(Int32, String).new 2.seconds
    cache.set 1, "Zwickelbier"
    sleep 3
    cache.expires(1).should be_nil
    cache.get(1).should be_nil
    cache.refresh(1, 5.seconds).should be_false
    cache.expires(1).should be_nil
    cache.keys.empty?.should be_true
  end

  it "key value pairs store expiration time" do
    time1 = 10.hours
    time2 = 6.seconds
    time3 = 2.days
    cache = StaleBeer::Cache(Int32, String).new
    cache.set 1, "Dunkelbier", time1
    cache.set 2, "Zwickelbier", time2
    cache.set 3, "Lager", time3
    sleep 1
    cache.expires(1).not_nil!.should be_close(time1, 2.seconds)
    cache.expires(2).not_nil!.should be_close(time2, 2.seconds)
    cache.expires(3).not_nil!.should be_close(time3, 2.seconds)
    cache.expires(4).should be_nil
  end

  it "key value pairs with custom expiration" do
    cache = StaleBeer::Cache(Int32, String).new 1.seconds
    cache.set 1, "Zwickelbier", 4.seconds
    cache.set 2, "Kellerbier", 6.minutes
    cache[3, 4.seconds] = "Lager"
    cache[4, 6.minutes] = "Dunkelbier"
    cache.keys.size.should eq(4)
    sleep 5
    cache.keys.size.should eq(2)
  end

  it "refresh key value pairs" do
    cache = StaleBeer::Cache(Int32, String).new 2.seconds
    cache.set 1, "Zwickelbier", 1.seconds
    cache.set 2, "Kellerbier"
    cache.set 3, "Dunkelbier", 6.minutes
    sleep 3
    cache.get(1).should be_nil
    cache.get(2).should be_nil
    cache.expires(3).not_nil!.should be_close(6.minutes, 4.seconds)
    cache.refresh 3, 10.minutes
    cache.expires(3).not_nil!.should be_close(10.minutes, 1.seconds)
  end

  it "purge all values" do
    cache = StaleBeer::Cache(Int32, String).new(5.seconds)
    cache.set 1, "Zwickelbier"
    cache.set 2, "Kellerbier"
    cache.set 3, "Lager"
    cache.purge
    cache.get(1).should be_nil
    cache.get(2).should be_nil
    cache.get(3).should be_nil
    cache.keys.empty?.should be_true
  end
end
