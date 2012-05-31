require 'spec_helper'

describe IsItWorking::MemcacheCheck do

  let(:status){ IsItWorking::Status.new(:memcache) }
  let(:memcache){ MemCache.new(['cache-1.example.com', 'cache-2.example.com']) }
  let(:servers){ memcache.servers }
  
  it "should succeed if all servers are responding" do
    check = IsItWorking::MemcacheCheck.new(:cache => memcache)
    servers.first.should_receive(:socket).and_return(mock(:socket))
    servers.last.should_receive(:socket).and_return(mock(:socket))
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is available"
  end

  it "should fail if any server is not responding" do
    check = IsItWorking::MemcacheCheck.new(:cache => memcache)
    servers.first.should_receive(:socket).and_return(mock(:socket))
    servers.last.should_receive(:socket).and_return(nil)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is not available"
  end

  it "should be able to get the MemCache object from an ActiveSupport::Cache" do
    require 'active_support/cache'
    rails_cache = ActiveSupport::Cache::MemCacheStore.new(memcache)
    check = IsItWorking::MemcacheCheck.new(:cache => rails_cache)
    servers.first.should_receive(:socket).and_return(mock(:socket))
    servers.last.should_receive(:socket).and_return(mock(:socket))
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "cache-1.example.com:11211 is available"
    status.messages.last.message.should == "cache-2.example.com:11211 is available"
  end

  it "should be able to alias the memcache host names in the output" do
    check = IsItWorking::MemcacheCheck.new(:cache => memcache, :alias => "memcache")
    servers.first.should_receive(:socket).and_return(mock(:socket))
    servers.last.should_receive(:socket).and_return(mock(:socket))
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "memcache 1 is available"
    status.messages.last.message.should == "memcache 2 is available"
  end
  
end
