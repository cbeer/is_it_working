module IsItWorking
  class RequestCheck < EnvCheck
    def call(status)
      request_env.each do |key, value|
        status.info "#{key}: #{value}"
      end
    end
    
    protected 
    def environment
      IsItWorking.request.env
    end
       
  end
end

