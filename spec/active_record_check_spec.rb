require 'spec_helper'

describe IsItWorking::ActiveRecordCheck do

  let(:status){ IsItWorking::Status.new(:active_record) }

  class IsItWorking::TestActiveRecord < ActiveRecord::Base
  end
  
  it "should succeed if the ActiveRecord connection is active" do
    connection = ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock(:connection))
    connection.reconnect!
    ActiveRecord::Base.stub!(:connection).and_return(connection)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "ActiveRecord::Base.connection is active"
  end
  
  it "should allow specifying the class to check the connection for" do
    connection = ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock(:connection))
    connection.reconnect!
    IsItWorking::TestActiveRecord.stub!(:connection).and_return(connection)
    check = IsItWorking::ActiveRecordCheck.new(:class => IsItWorking::TestActiveRecord)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "IsItWorking::TestActiveRecord.connection is active"
  end

  it "should succeed if the ActiveRecord connection can be reconnected" do
    connection = ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock(:connection))
    connection.disconnect!
    ActiveRecord::Base.stub!(:connection).and_return(connection)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "ActiveRecord::Base.connection is active"
  end

  it "should fail if the ActiveRecord connection is not active" do
    connection = ActiveRecord::ConnectionAdapters::AbstractAdapter.new(mock(:connection))
    connection.disconnect!
    connection.stub!(:verify!)
    ActiveRecord::Base.stub!(:connection).and_return(connection)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "ActiveRecord::Base.connection is not active"
  end
  
end
