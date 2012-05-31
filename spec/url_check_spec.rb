require 'spec_helper'
require 'webmock/rspec'

describe IsItWorking::UrlCheck do

  before :all do
    WebMock.disable_net_connect!
  end

  after :all do
    WebMock.allow_net_connect!
  end

  after :each do
    WebMock.reset!
  end

  let(:status){ IsItWorking::Status.new(:url) }

  it "should succeed if the URL returns a 2xx response" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [200, "Success"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1")
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 responded with response '200 Success'"
  end

  it "should fail if the URL returns a 1xx response" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [150, "Continue"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1")
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 failed with response '150 Continue'"
  end

  it "should fail if the URL returns a 3xx response" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [302, "Found"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1")
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 failed with response '302 Found'"
  end

  it "should fail if the URL returns a 4xx response" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [404, "Not Found"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1")
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 failed with response '404 Not Found'"
  end

  it "should fail if the URL returns a 5xx response" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [503, "Service Unavailable"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1")
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 failed with response '503 Service Unavailable'"
  end

  it "should send basic authentication" do
    stub_request(:get, "user:passwd@example.com/test?a=1").to_return(:status => [200, "Success"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1", :username => "user", :password => "passwd")
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 responded with response '200 Success'"
  end

  it "should send headers with the request" do
    stub_request(:get, "example.com/test?a=1").to_return(:status => [200, "Success"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test?a=1", :headers => {"Accept-Encoding" => "gzip"})
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET http://example.com/test?a=1 responded with response '200 Success'"
    WebMock.should have_requested(:get, "example.com/test?a=1").with(:headers => {"Accept-Encoding" => "gzip"})
  end

  it "should use SSL connection if URL is HTTPS" do
    http = Net::HTTP.new('localhost')
    Net::HTTP.should_receive(:new).with('localhost', 443).and_return(http)
    request = Net::HTTP::Get.new("/test?a=1")
    Net::HTTP::Get.should_receive(:new).with("/test?a=1", {}).and_return(request)
    http.should_receive(:start).and_yield
    http.should_receive(:request).with(request).and_return(Net::HTTPSuccess.new(nil, "200", "Success"))

    check = IsItWorking::UrlCheck.new(:get => "https://localhost/test?a=1")
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET https://localhost/test?a=1 responded with response '200 Success'"
    http.use_ssl?.should == true
    http.verify_mode.should == OpenSSL::SSL::VERIFY_PEER
  end

  it "should be able to alias the URL in the output" do
    stub_request(:get, "example.com/test").to_return(:status => [200, "Success"])
    check = IsItWorking::UrlCheck.new(:get => "http://example.com/test", :alias => "service ping URL")
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET service ping URL responded with response '200 Success'"
  end

  it "should try to get the URL through a proxy" do
    http = Net::HTTP.new('localhost')
    Net::HTTP.should_receive(:Proxy).with('localhost', 8080, "user", "passwd").and_return(Net::HTTP)
    Net::HTTP.should_receive(:new).with('localhost', 80).and_return(http)
    request = Net::HTTP::Get.new("/test?a=1")
    Net::HTTP::Get.should_receive(:new).with("/test?a=1", {}).and_return(request)
    http.should_receive(:start).and_yield
    http.should_receive(:request).with(request).and_return(Net::HTTPSuccess.new(nil, "200", "Success"))

    check = IsItWorking::UrlCheck.new(:get => "http://localhost/test?a=1", :proxy => {:host => "localhost", :port => 8080, :username => "user", :password => "passwd"})
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET http://localhost/test?a=1 responded with response '200 Success'"
  end

  it "should set open and read timeouts" do
    http = Net::HTTP.new('localhost')
    Net::HTTP.should_receive(:new).with('localhost', 80).and_return(http)
    request = Net::HTTP::Get.new("/test?a=1")
    Net::HTTP::Get.should_receive(:new).with("/test?a=1", {}).and_return(request)
    http.should_receive(:start).and_yield
    http.should_receive(:request).with(request).and_return(Net::HTTPSuccess.new(nil, "200", "Success"))

    check = IsItWorking::UrlCheck.new(:get => "http://localhost/test?a=1", :open_timeout => 1, :read_timeout => 2)
    check.call(status)
    status.should be_success
    status.messages.first.message.should == "GET http://localhost/test?a=1 responded with response '200 Success'"
    http.open_timeout.should == 1
    http.read_timeout.should == 2
  end

  it "should fail on a timeout" do
    http = Net::HTTP.new('localhost')
    Net::HTTP.should_receive(:new).with('localhost', 80).and_return(http)
    request = Net::HTTP::Get.new("/test?a=1")
    Net::HTTP::Get.should_receive(:new).with("/test?a=1", {}).and_return(request)
    http.should_receive(:start).and_raise(TimeoutError)

    check = IsItWorking::UrlCheck.new(:get => "http://localhost/test?a=1", :open_timeout => 1, :read_timeout => 2)
    check.call(status)
    status.should_not be_success
    status.messages.first.message.should match(/GET http:\/\/localhost\/test\?a=1 timed out after .* seconds/)
  end
end
