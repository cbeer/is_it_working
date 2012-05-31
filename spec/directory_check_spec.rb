require 'spec_helper'

describe IsItWorking::DirectoryCheck do
  
  let(:status){ IsItWorking::Status.new(:directory) }
  let(:directory_path){ File.expand_path(".") }
  
  it "should fail if a directory can't be found" do
    check = IsItWorking::DirectoryCheck.new(:path => File.expand_path("../no_such_thing", __FILE__))
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should include("does not exist")
  end
  
  it "should fail if a path isn't a directory" do
    check = IsItWorking::DirectoryCheck.new(:path => __FILE__)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should include("is not a directory")
  end
  
  it "should succeed if a directory exists" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path)
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => false, :writable? => false))
    check.call(status)
    status.should be_success
    status.messages.first.message.should include("exists")
  end
  
  it "should fail if a directory is not readable" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path, :permission => :read)
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => false, :writable? => true))
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should include("is not readable")
  end
  
  it "should fail if a directory is not writable" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path, :permission => :write)
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => true, :writable? => false))
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should include("is not writable")
  end
  
  it "should succeed if a directory exists and is readable" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path, :permission => :read)
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => true, :writable? => false))
    check.call(status)
    status.should be_success
    status.messages.first.message.should include("exists with")
  end
  
  it "should succeed if a directory exists and is writable" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path, :permission => :write)
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => false, :writable? => true))
    check.call(status)
    status.should be_success
    status.messages.first.message.should include("exists with")
  end
  
  it "should succeed if a directory exists and is readable and writable" do
    check = IsItWorking::DirectoryCheck.new(:path => directory_path, :permission => [:read, :write])
    File.should_receive(:stat).with(directory_path).and_return(mock(:stat, :directory? => true, :readable? => true, :writable? => true))
    check.call(status)
    status.should be_success
    status.messages.first.message.should include("exists with")
  end
  
end
