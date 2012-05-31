require 'spec_helper'

describe IsItWorking::ActionMailerCheck do

  let(:status){ IsItWorking::Status.new(:ping) }
  
  it "should succeed if the default mail host is accepting connections" do
    ActionMailer::Base.smtp_settings[:address] = 'localhost'
    ActionMailer::Base.smtp_settings[:port] = 25
    TCPSocket.should_receive(:new).with('localhost', 25).and_return(mock(:socket, :close => true))
    check = IsItWorking::ActionMailerCheck.new
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "ActionMailer::Base is accepting connections on port 25"
  end
  
  it "should succeed if the default mail host is not accepting connections" do
    ActionMailer::Base.smtp_settings[:address] = 'localhost'
    ActionMailer::Base.smtp_settings[:port] = 25
    TCPSocket.should_receive(:new).with('localhost', 25).and_raise(Errno::ECONNREFUSED)
    check = IsItWorking::ActionMailerCheck.new
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "ActionMailer::Base is not accepting connections on port 25"
  end
  
  it "should get the smtp configuration from a specified ActionMailer class" do
    class IsItWorking::ActionMailerCheck::Tester < ActionMailer::Base
    end
    
    IsItWorking::ActionMailerCheck::Tester.smtp_settings[:address] = 'mail.example.com'
    IsItWorking::ActionMailerCheck::Tester.smtp_settings[:port] = 'smtp'
    TCPSocket.should_receive(:new).with('mail.example.com', 'smtp').and_return(mock(:socket, :close => true))
    check = IsItWorking::ActionMailerCheck.new(:class => IsItWorking::ActionMailerCheck::Tester)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "IsItWorking::ActionMailerCheck::Tester is accepting connections on port \"smtp\""
  end
  
  it "should allow aliasing the ActionMailer host alias" do
    ActionMailer::Base.smtp_settings[:address] = 'localhost'
    ActionMailer::Base.smtp_settings[:port] = 25
    TCPSocket.should_receive(:new).with('localhost', 25).and_return(mock(:socket, :close => true))
    check = IsItWorking::ActionMailerCheck.new(:alias => "smtp host")
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "smtp host is accepting connections on port 25"
  end
  
  
end
