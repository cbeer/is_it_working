require 'action_mailer'

module IsItWorking
  # Check if the mail server configured for ActionMailer is responding.
  #
  # The ActionMailer class that yields the configuration can be specified with the <tt>:class</tt>
  # option. By default this will be ActionMailer::Base. You can also set a <tt>:timeout</tt> option
  # for how long to wait for a response and an <tt>:alias</tt> option which will be the name reported
  # back by the check (defaults to the ActionMailer class).
  #
  # === Example
  #
  #   IsItWorking::Handler.new do |h|
  #     h.check :action_mailer, :class => UserMailer
  #   end
  class ActionMailerCheck < PingCheck
    def initialize(options={})
      options = options.dup
      klass = options.delete(:class) || ActionMailer::Base
      options.merge!(:host => klass.smtp_settings[:address], :port => klass.smtp_settings[:port] || 'smtp')
      options[:alias] ||= klass.name
      super(options)
    end
  end
end
