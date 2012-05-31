require 'net/http'
require 'net/https'

module IsItWorking
  # Check if getting a URL returns a successful response. Only responses in the range 2xx or 304
  # are considered successful. Redirects will not be followed.
  #
  # Available options are:
  #
  # * <tt>:get</tt> - The URL to get.
  # * <tt>:headers</tt> - Hash of headers to send with the request
  # * <tt>:proxy</tt> - Hash of proxy server information. The hash must contain a <tt>:host</tt> key and may contain <tt>:port</tt>, <tt>:username</tt>, and <tt>:password</tt>
  # * <tt>:username</tt> - Username to use for Basic Authentication
  # * <tt>:password</tt> - Password to use for Basic Authentication
  # * <tt>:open_timeout</tt> - Time in seconds to wait for opening the connection (defaults to 5 seconds)
  # * <tt>:read_timeout</tt> - Time in seconds to wait for data from the connection (defaults to 10 seconds)
  # * <tt>:alias</tt> - Alias used for reporting in case making the URL known to the world could provide a security risk.
  #
  # === Example
  #
  #   IsItWorking::Handler.new do |h|
  #     h.check :url, :get => "http://services.example.com/api", :headers => {"Accept" => "text/xml"}
  #   end
  class UrlCheck
    def initialize(options={})
      raise ArgumentError.new(":get must provide the URL to check") unless options[:get]
      @uri = URI.parse(options[:get])
      @headers = options[:headers] || {}
      @proxy = options[:proxy]
      @username = options[:username]
      @password = options[:password]
      @open_timeout = options[:open_timeout] || 5
      @read_timeout = options[:read_timeout] || 10
      @alias = options[:alias] || options[:get]
    end
    
    def call(status)
      t = Time.now
      response = perform_http_request
      if response.is_a?(Net::HTTPSuccess)
        status.ok("GET #{@alias} responded with response '#{response.code} #{response.message}'")
      else
        status.fail("GET #{@alias} failed with response '#{response.code} #{response.message}'")
      end
    rescue Timeout::Error
      status.fail("GET #{@alias} timed out after #{Time.now - t} seconds")
    end
    
    private
      # Create an HTTP object with the options set.
      def instantiate_http #:nodoc:
        http_class = nil

        if @proxy && @proxy[:host]
          http_class = Net::HTTP::Proxy(@proxy[:host], @proxy[:port], @proxy[:username], @proxy[:password])
        else
          http_class = Net::HTTP
        end

        http = http_class.new(@uri.host, @uri.port)
        if @uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
        http.open_timeout = @open_timeout
        http.read_timeout = @read_timeout

        return http
      end
    
      # Perform an HTTP request and return the response
      def perform_http_request #:nodoc:
        request = Net::HTTP::Get.new(@uri.request_uri, @headers)
        request.basic_auth(@username, @password) if @username || @password
        http = instantiate_http
        http.start do
          http.request(request)
        end
      end
  end
end
