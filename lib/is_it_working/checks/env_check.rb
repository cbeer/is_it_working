module IsItWorking
  class EnvCheck
    def initialize(options={})
      @filter = options[:filter]
    end
    
    def call(status)

      request_env.each do |key, value|
        status.info "#{key}: #{value}"
      end
    end
    
   protected 

    def request_env 
      @request_env ||= begin
         h = {}

         environment.each_pair do |key,value|
           if @filter.nil? or key.to_s =~ @filter
             h[key] = value.to_s
           end
         end
         h
      end
    end

    def environment
      ENV
    end
       
  end
end
