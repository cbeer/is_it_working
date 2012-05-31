module IsItWorking
  class DirectoryCheck
    # Check if a file system directory exists and has the correct access. This
    # can be very useful to check if the application relies on a shared file sytem
    # being mounted. The <tt>:path</tt> options must be supplied to the initializer. You
    # may also supply an <tt>:permission</tt> option with the values <tt>:read</tt>, <tt>:write</tt>, or
    # <tt>[:read, :write]</tt> to check the permission on the directory as well.
    #
    # === Example
    #
    #   IsItWorking::Handler.new do |h|
    #     h.check :directory, :path => "/var/shared/myapp", :permission => [:read, :write]
    #   end
    def initialize (options={})
      raise ArgumentError.new(":path not specified") unless options[:path]
      @path = File.expand_path(options[:path])
      @permission = options[:permission]
      @permission = [@permission] if @permission && !@permission.is_a?(Array)
    end
    
    def call(status)
      stat = File.stat(@path) if File.exist?(@path)
      if stat
        if stat.directory?
          if @permission
            if @permission.include?(:read) && !stat.readable?
              status.fail("#{@path} is not readable by #{ENV['USER']}")
            elsif @permission.include?(:write) && !stat.writable?
              status.fail("#{@path} is not writable by #{ENV['USER']}")
            else
              status.ok("#{@path} exists with #{@permission.collect{|a| a.to_s}.join('/')} permission")
            end
          else
            status.ok("#{@path} exists")
          end
        else
          status.fail("#{@path} is not a directory")
        end
      else
        status.fail("#{@path} does not exist")
      end
    end
  end
end
