module IsItWorking
  # This class is used to pass the status of a monitoring check. Each status can have multiple
  # messages added to it by calling the +ok+ or +fail+ methods. The status check will only be
  # considered a success if all messages are ok.
  class Status
    # This class is used to contain individual status messages. Eache method can represent either
    # and +ok+ message or a +fail+ message.
    class Message
      attr_reader :message

      def initialize(message, ok)
        @message = message
        @ok = ok
      end

      def ok?
        @ok
      end
    end

    # The name of the status check for display purposes.
    attr_reader :name

    # The messages set on the status check.
    attr_reader :messages

    # The amount of time it takes to complete the status check.
    attr_accessor :time

    def initialize(name)
      @name = name
      @messages = []
    end

    # Add a message indicating that the check passed.
    def ok(message)
      @messages << Message.new(message, true)
    end

    # Add a message indicating that the check failed.
    def fail(message)
      @messages << Message.new(message, false)
    end

    # Returns +true+ only if all checks were OK.
    def success?
      @messages.all?{|m| m.ok?}
    end
  end
end
