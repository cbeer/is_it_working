require 'spec_helper'

describe IsItWorking::Handler do
  
  it "should lookup filters from the pre-defined checks" do
    handler = IsItWorking::Handler.new do |h|
      h.check :directory, :path => ".", :permissions => :read
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("directory")
  end
  
  it "should use blocks as filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("Okey dokey")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("block - Okey dokey")
  end
  
  it "should use object as filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :lambda, lambda{|status| status.ok("A-okay")}
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("lambda - A-okay")
  end
  
  it "should create asynchronous filters by default" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("Okey dokey")
      end
    end
    runner = IsItWorking::Filter::AsyncRunner.new{}
    IsItWorking::Filter::AsyncRunner.should_receive(:new).and_return(runner)
    response = handler.call({})
  end
  
  it "should be able to create synchronous filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block, :async => false do |status|
        status.ok("Okey dokey")
      end
    end
    runner = IsItWorking::Filter::SyncRunner.new{}
    IsItWorking::Filter::SyncRunner.should_receive(:new).and_return(runner)
    response = handler.call({})
  end
  
  it "should work with synchronous checks" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block, :async => false do |status|
        status.ok("Okey dokey")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("block - Okey dokey")
  end
  
  it "should return a success response if all checks pass" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("success")
      end
      h.check :block do |status|
        status.ok("worked")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("block - success")
    response.last.flatten.join("").should include("block - worked")
  end
  
  it "should return an error response if any check fails" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("success")
      end
      h.check :block do |status|
        status.fail("down")
      end
    end
    response = handler.call({})
    response.first.should == 500
    response.last.flatten.join("").should include("block - success")
    response.last.flatten.join("").should include("block - down")
  end
  
  it "should be able to be used in a middleware stack with the route /is_it_working" do
    app_response = [200, {"Content-Type" => "text/plain"}, ["OK"]]
    app = lambda{|env| app_response}
    check_called = false
    stack = IsItWorking::Handler.new(app) do |h|
      h.check(:test){|status| check_called = true; status.ok("Woot!")}
    end
    
    stack.call("PATH_INFO" => "/").should == app_response
    check_called.should == false
    stack.call("PATH_INFO" => "/is_it_working").last.flatten.join("").should include("Woot!")
    check_called.should == true
  end
  
  it "should be able to be used in a middleware stack with a custom route" do
    app_response = [200, {"Content-Type" => "text/plain"}, ["OK"]]
    app = lambda{|env| app_response}
    check_called = false
    stack = IsItWorking::Handler.new(app, "/woot") do |h|
      h.check(:test){|status| check_called = true; status.ok("Woot!")}
    end
    
    stack.call("PATH_INFO" => "/is_it_working").should == app_response
    check_called.should == false
    stack.call("PATH_INFO" => "/woot").last.flatten.join("").should include("Woot!")
    check_called.should == true
  end
  
  it "should be able to synchronize access to a block" do
    handler = IsItWorking::Handler.new
    handler.synchronize{1}.should == 1
    handler.synchronize{2}.should == 2
  end
  
  it "should be able to set the host name reported in the output" do
    handler = IsItWorking::Handler.new
    handler.hostname = "woot"
    handler.call("PATH_INFO" => "/is_it_working").last.join("").should include("woot")
  end
end
