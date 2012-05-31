require File.expand_path('../spec_helper', __FILE__)

describe IsItWorking::Filter do
  
  it "should have a name" do
    filter = IsItWorking::Filter.new(:test, lambda{})
    filter.name.should == :test
  end
  
  it "should run a check and return a thread" do
    check = lambda do |status|
      status.ok("success")
    end
    
    filter = IsItWorking::Filter.new(:test, check)
    runner = filter.run
    status = runner.filter_status
    runner.join
    status.should be_success
    status.messages.first.message.should == "success"
    status.time.should_not be_nil
  end
  
  it "should run a check and recue an errors" do
    check = lambda do |status|
      raise "boom!"
    end
    
    filter = IsItWorking::Filter.new(:test, check)
    runner = filter.run
    status = runner.filter_status
    runner.join
    status.should_not be_success
    status.messages.first.message.should include("boom")
    status.time.should_not be_nil
  end
  
  it "should run multiple filters and return their statuses" do
    filter_1 = IsItWorking::Filter.new(:test, lambda{|status| status.ok("OK")})
    filter_2 = IsItWorking::Filter.new(:test, lambda{|status| status.fail("FAIL")})
    statuses = IsItWorking::Filter.run_filters([filter_1, filter_2])
    statuses.first.should be_success
    statuses.last.should_not be_success
  end
  
end
