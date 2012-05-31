require 'socket'
require 'timeout'

module IsItWorking
  class PingCheck
    # Check if a host is reachable and accepting connections on a specified port.
    #
    # The host and port to ping are specified with the <tt>:host</tt> and <tt>:port</tt> options. The port
    # can be either a port number or port name for a well known port (i.e. "smtp" and 25 are
    # equivalent). The default timeout to wait for a response is 2 seconds. This can be
    # changed with the <tt>:timeout</tt> option.
    #
    # By default, the host name will be included in the output. If this could pose a security
    # risk by making the existence of the host known to the world, you can supply the <tt>:alias</tt>
    # option which will be used for output purposes. In general, you should supply this option
    # unless the host is on a private network behind a firewall.
    #
    # === Example
    #
    #   IsItWorking::Handler.new do |h|
    #     h.check :ping, :host => "example.com", :port => "ftp", :timeout => 4
    #   end
    def initialize(options={})
      @host = options[:host]
      raise ArgumentError.new(":host not specified") unless @host
      @port = options[:port]
      raise ArgumentError.new(":port not specified") unless @port
      @timeout = options[:timeout] || 2
      @alias = options[:alias] || @host
    end
    
    def call(status)
      begin
        ping(@host, @port)
        status.ok("#{@alias} is accepting connections on port #{@port.inspect}")
      rescue Errno::ECONNREFUSED
        status.fail("#{@alias} is not accepting connections on port #{@port.inspect}")
      rescue SocketError => e
        status.fail("connection to #{@alias} on port #{@port.inspect} failed with '#{e.message}'")
      rescue Timeout::Error
        status.fail("#{@alias} did not respond on port #{@port.inspect} within #{@timeout} seconds")
      end
    end
    
    def ping(host, port)
      timeout(@timeout) do
        s = TCPSocket.new(host, port)
        s.close
      end
      true
    end
  end
end
