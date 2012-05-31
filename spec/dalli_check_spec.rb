require 'spec_helper'

describe IsItWorking::DalliCheck do

  let(:status){ IsItWorking::Status.new(:memcache) }
  let(:memcache){ Dalli::Client.new(['cache-1.example.com', 'cache-2.example.com']) }
  let(:servers){ memcache.send(:ring).servers }

  it "should succeed if all servers are responding" do
    check = IsItWorking::DalliCheck.new(:cache => memcache)
    servers.first.should_receive(:alive?).and_return(true)
    servers.last.should_receive(:alive?).and_return(true)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is available"
  end

  it "should fail if any server is not responding" do
    check = IsItWorking::DalliCheck.new(:cache => memcache)
    servers.first.should_receive(:alive?).and_return(true)
    servers.last.should_receive(:alive?).and_return(false)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is not available"
  end

  it "should be able to get the MemCache object from an ActiveSupport::Cache" do
    require 'active_support/cache'
    require 'active_support/cache/dalli_store'
    ActiveSupport::Cache::DalliStore.should_receive(:new).with('cache-1.example.com', 'cache-2.example.com').and_return(memcache)
    rails_cache = ActiveSupport::Cache::DalliStore.new('cache-1.example.com', 'cache-2.example.com')
    check = IsItWorking::DalliCheck.new(:cache => rails_cache)
    servers.first.should_receive(:alive?).and_return(true)
    servers.last.should_receive(:alive?).and_return(true)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is available"
  end

  it "should be able to alias the memcache host names in the output" do
    check = IsItWorking::DalliCheck.new(:cache => memcache, :alias => "memcache")
    servers.first.should_receive(:alive?).and_return(true)
    servers.last.should_receive(:alive?).and_return(true)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "memcache 1 is available"
    status.messages.last.message.should == "memcache 2 is available"
  end

end
