require 'dalli'

module IsItWorking
  class DalliCheck
    # Check if all the memcached servers in a cluster are responding.
    # The memcache cluster to check is specified with the <tt>:cache</tt> options. The
    # value can be either a Dalli::Client object (from the dalli gem) or an
    # ActiveSupport::Cache::DalliStore (i.e. Rails.cache).
    #
    # If making the IP addresses of the memcache servers known to the world could
    # pose a security risk because they are not on a private network behind a firewall,
    # you can provide the <tt>:alias</tt> option to change the host names that are reported.
    #
    # === Example
    #
    #   IsItWorking::Handler.new do |h|
    #     h.check :dalli, :cache => Rails.cache, :alias => "memcache server"
    #   end
    def initialize(options={})
      memcache = options[:cache]
      raise ArgumentError.new(":cache not specified") unless memcache
      unless memcache.is_a?(Dalli::Client)
        if defined?(ActiveSupport::Cache::DalliStore) && memcache.is_a?(ActiveSupport::Cache::DalliStore)
          # Big hack to get the MemCache object from Rails.cache
          @memcache = memcache.instance_variable_get(:@data)
        else
          raise ArgumentError.new("#{memcache} is not a Dalli::Client")
        end
      else
        @memcache = memcache
      end
      @alias = options[:alias]
    end

    def call(status)
      servers = @memcache.send(:ring).servers
      servers.each_with_index do |server, i|
        public_host_name = @alias ? "#{@alias} #{i + 1}" : "#{server.hostname}:#{server.port}"

        if server.alive?
          status.ok("#{public_host_name} is available")
        else
          status.fail("#{public_host_name} is not available")
        end
      end
    end
  end
end
