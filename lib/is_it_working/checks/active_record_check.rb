require 'active_record'

module IsItWorking
  # Check if the database connection used by an ActiveRecord class is up.
  #
  # The ActiveRecord class that yields the connection can be specified with the <tt>:class</tt>
  # option. By default this will be ActiveRecord::Base.
  #
  # === Example
  #
  #   IsItWorking::Handler.new do |h|
  #     h.check :active_record, :class => User
  #   end
  class ActiveRecordCheck
    def initialize(options={})
      @class = options[:class] || ActiveRecord::Base
    end
    
    def call(status)
      @class.connection.verify!
      if @class.connection.active?
        status.ok("#{@class}.connection is active")
      else
        status.fail("#{@class}.connection is not active")
      end
    end
  end
end
