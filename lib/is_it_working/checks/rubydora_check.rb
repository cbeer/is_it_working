module IsItWorking
  class RubydoraCheck
    def initialize(options={})
      @client = options[:client]
      raise ArgumentError.new(":client not specified") unless @client
      @host = @client.client.url
      @timeout = options[:timeout] || 2
      @alias = options[:alias] || @host
    end
    
    def call(status)
      begin
        ping
        status.ok("service active")
        ["repositoryName", "repositoryBaseURL", "repositoryVersion"].each do |key|
          status.info("#{key} - #{profile[key]}")
        end
      rescue Errno::ECONNREFUSED
        status.fail("#{@alias} is not accepting connections on port #{@port.inspect}")
      rescue SocketError => e
        status.fail("connection to #{@alias} on port #{@port.inspect} failed with '#{e.message}'")
      rescue Timeout::Error
        status.fail("#{@alias} did not respond on port #{@port.inspect} within #{@timeout} seconds")
      end
    end
    
    def profile 
      @luke ||= begin
                  ActiveFedora::Base.connection_for_pid(0).profile
                rescue
                  {}
                end
    end

    def ping
      timeout(@timeout) do
        s = TCPSocket.new(uri.host, uri.port)
        s.close
      end
      true
    end

    def uri
      URI(@host)
    end
  end
end

