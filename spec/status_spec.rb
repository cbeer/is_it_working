require File.expand_path('../spec_helper', __FILE__)

describe IsItWorking::Status do
  
  let(:status){ IsItWorking::Status.new(:test) }
  
  it "should have a name" do
    status.name.should == :test
  end
  
  it "should have errors" do
    status.fail("boom")
    status.should_not be_success
    status.messages.size.should == 1
    status.messages.first.should_not be_ok
    status.messages.first.message.should == "boom"
  end
  
  it "should have successes" do
    status.ok("wow")
    status.should be_success
    status.messages.size.should == 1
    status.messages.first.should be_ok
    status.messages.first.message.should == "wow"
  end
  
  it "should have both errors and successes" do
    status.fail("boom")
    status.ok("wow")
    status.should_not be_success
    status.messages.size.should == 2
    status.messages.first.should_not be_ok
    status.messages.first.message.should == "boom"
    status.messages.last.should be_ok
    status.messages.last.message.should == "wow"
  end
  
  it "should have a time" do
    status.time.should == nil
    status.time = 0.1
    status.time.should == 0.1
  end
  
end
