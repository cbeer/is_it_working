module IsItWorking
  # Rack handler that will run a set of status checks on the application and report the
  # results. The results are formatted in plain text. If any of the checks fails, the
  # response code will be 500 Server Error.
  #
  # The checks to perform are defined in the initialization block. Each check needs a name
  # and can either be a predefined check, block, or an object that responds to the +call+
  # method. When a check is called, its +call+ method will be called with a Status object.
  #
  # === Example
  #
  #   IsItWorkingHandler.new do |h|
  #     # Predefined check to determine if a directory is accessible
  #     h.check :directory, "/var/myapp", :read, :write
  #
  #     # Custom check using a block
  #     h.check :solr do
  #       SolrServer.available? ? ok("solr is up") : fail("solr is down")
  #     end
  #   end
  class Handler
    PATH_INFO = "PATH_INFO".freeze
    
    # Create a new handler. This method can take a block which will yield itself so it can
    # be configured.
    #
    # The handler can be set up in one of two ways. If no arguments are supplied, it will
    # return a regular Rack handler that can be used with a rackup +run+ method or in a
    # Rails 3+ routes.rb file. Otherwise, an application stack can be supplied in the first
    # argument and a routing path in the second (defaults to <tt>/is_it_working</tt>) so
    # it can be used with the rackup +use+ method or in Rails.middleware.
    def initialize(app=nil, route_path="/is_it_working", &block)
      @app = app
      @route_path = route_path
      @hostname = `hostname`.chomp
      @filters = []
      @mutex = Mutex.new
      yield self if block_given?
    end

    def call(env)
      if @app.nil? || env[PATH_INFO] == @route_path
        statuses = []
        t = Time.now
        statuses = Filter.run_filters(@filters)
        render(statuses, Time.now - t)
      else
        @app.call(env)
      end
    end

    # Set the hostname reported the the application is running on. By default this is set
    # the system hostname. You should override it if the value reported as the hostname by
    # the system is not useful or if exposing it publicly would create a security risk.
    def hostname=(val)
      @hostname = val
    end
    
    # Add a status check to the handler.
    #
    # If a block is given, it will be used as the status check and will be yielded to
    # with a Status object.
    #
    # If the name matches one of the pre-defined status check classes, a new instance will
    # be created using the rest of the arguments as the arguments to the initializer. The
    # pre-defined classes are:
    #
    # * <tt>:action_mailer</tt> - Check if the send mail configuration used by ActionMailer is available
    # * <tt>:active_record</tt> - Check if the database connection for an ActiveRecord class is up
    # * <tt>:dalli</tt> - DalliCheck checks if all the servers in a MemCache cluster are available using dalli
    # * <tt>:directory</tt> - DirectoryCheck checks for the accessibilty of a file system directory
    # * <tt>:memcache</tt> - MemcacheCheck checks if all the servers in a MemCache cluster are available using memcache-client
    # * <tt>:ping</tt> - Check if a host is reachable and accepting connections on a port
    # * <tt>:url</tt> - Check if a getting a URL returns a success response
    def check (name, *options_or_check, &block)
      raise ArgumentError("Too many arguments to #{self.class.name}#check") if options_or_check.size > 2
      check = nil
      options = {:async => true}
      
      unless options_or_check.empty?
        if options_or_check[0].is_a?(Hash)
          options = options.merge(options_or_check[0])
        else
          check = options_or_check[0]
        end
        if options_or_check[1].is_a?(Hash)
          options = options.merge(options_or_check[1])
        end
      end
      
      unless check
        if block
          check = block
        else
          check = lookup_check(name, options)
        end
      end
      
      @filters << Filter.new(name, check, options[:async])
    end
    
    # Helper method to synchronize a block of code so it can be thread safe.
    # This method uses a Mutex and is not re-entrant. The synchronization will
    # be only on calls to this handler.
    def synchronize
      @mutex.synchronize do
        yield
      end
    end

    protected
      # Lookup a status check filter from the name and arguments
      def lookup_check(name, options) #:nodoc:
        check_class_name = "#{name.to_s.gsub(/(^|_)([a-z])/){|m| m.sub('_', '').upcase}}Check"
        check = nil
        if IsItWorking.const_defined?(check_class_name)
          check_class = IsItWorking.const_get(check_class_name)
          check = check_class.new(options)
        else
          raise ArgumentError.new("Check not defined #{check_class_name}")
        end
        check
      end

      # Output the plain text response from calling all the filters.
      def render(statuses, elapsed_time) #:nodoc:
        fail = statuses.all?{|s| s.success?}
        headers = {
          "Content-Type" => "text/plain; charset=utf8",
          "Cache-Control" => "no-cache",
          "Date" => Time.now.httpdate,
        }
        
        messages = []
        statuses.each do |status|
          status.messages.each do |m|
            messages << "#{m.ok? ? 'OK:  ' : 'FAIL:'} #{status.name} - #{m.message} (#{status.time ? sprintf('%0.000f', status.time * 1000) : '?'}ms)"
          end
        end
        
        info = []
        info << "Host: #{@hostname}" unless @hostname.size == 0
        info << "PID:  #{$$}"
        info << "Timestamp: #{Time.now.iso8601}"
        info << "Elapsed Time: #{(elapsed_time * 1000).round}ms"
        
        code = (fail ? 200 : 500)
        
        [code, headers, [info.join("\n"), "\n\n", messages.join("\n")]]
      end
  end
end
