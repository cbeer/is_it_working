module IsItWorking
  # This class is used to pass the status of a monitoring check. Each status can have multiple
  # messages added to it by calling the +ok+ or +fail+ methods. The status check will only be
  # considered a success if all messages are ok.
  class Status
    # This class is used to contain individual status messages. Eache method can represent either
    # and +ok+ message or a +fail+ message.
    class Message
      class <<self
        attr_accessor :ok_states
      end

      self.ok_states = [:ok, :info]

      attr_reader :message
      attr_reader :state


      def initialize(message, state)
        @message = message
        @state = state
      end

      def ok?
        self.class.ok_states.include? state
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
      @messages << Message.new(message, :ok)
    end

    def info(message)
      @messages << Message.new(message, :info)
    end

    # Add a message indicating that the check failed.
    def fail(message)
      @messages << Message.new(message, :fail)
    end

    # Returns +true+ only if all checks were OK.
    def success?
      @messages.all?{|m| m.ok?}
    end
  end
end
