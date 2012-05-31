require 'spec_helper'

describe IsItWorking::PingCheck do

  let(:status){ IsItWorking::Status.new(:ping) }

  it "should succeed if the host is accepting connections on the specified port" do
    server = TCPServer.new(51123)
    begin
      check = IsItWorking::PingCheck.new(:host => "localhost", :port => 51123)
      check.call(status)
      status.should be_success
      status.messages.first.message.should == "localhost is accepting connections on port 51123"
    ensure
      server.close
    end
  end

  it "should fail if the host is not accepting connections on the specified port" do
    check = IsItWorking::PingCheck.new(:host => "localhost", :port => 51123)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "localhost is not accepting connections on port 51123"
  end

  it "should fail if the host cannot be found" do
    check = IsItWorking::PingCheck.new(:host => "127.0.0.256", :port => 51123)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should include("failed")
  end
  
  it "should fail if the server takes too long to respond" do
    check = IsItWorking::PingCheck.new(:host => "127.0.0.255", :port => 51123, :timeout => 0.01)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "127.0.0.255 did not respond on port 51123 within 0.01 seconds"
  end

  it "should be able to alias the host name in the output" do
    check = IsItWorking::PingCheck.new(:host => "localhost", :port => 51123, :alias => "secret server")
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "secret server is not accepting connections on port 51123"
  end
  
end
