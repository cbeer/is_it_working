require 'memcache'

module IsItWorking
  class MemcacheCheck
    # Check if all the memcached servers in a cluster are responding.
    # The memcache cluster to check is specified with the <tt>:cache</tt> options. The
    # value can be either a MemCache object (from the memcache-client gem) or an
    # ActiveSupport::Cache::MemCacheStore (i.e. Rails.cache).
    #
    # If making the IP addresses of the memcache servers known to the world could
    # pose a security risk because they are not on a private network behind a firewall,
    # you can provide the <tt>:alias</tt> option to change the host names that are reported.
    #
    # === Example
    #
    #   IsItWorking::Handler.new do |h|
    #     h.check :memcache, :cache => Rails.cache, :alias => "memcache server"
    #   end
    def initialize(options={})
      memcache = options[:cache]
      raise ArgumentError.new(":cache not specified") unless memcache
      unless memcache.is_a?(MemCache)
        if defined?(ActiveSupport::Cache::MemCacheStore) && memcache.is_a?(ActiveSupport::Cache::MemCacheStore)
          # Big hack to get the MemCache object from Rails.cache
          @memcache = memcache.instance_variable_get(:@data)
        else
          raise ArgumentError.new("#{memcache} is not a MemCache")
        end
      else
        @memcache = memcache
      end
      @alias = options[:alias]
    end
    
    def call(status)
      @memcache.servers.each_with_index do |server, i|
        public_host_name = @alias ? "#{@alias} #{i + 1}" : "#{server.host}:#{server.port}"
        if server.alive?
          status.ok("#{public_host_name} is available")
        else
          status.fail("#{public_host_name} is not available")
        end
      end
    end
  end
end
