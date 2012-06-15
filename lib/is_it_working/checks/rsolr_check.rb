module IsItWorking
  class RsolrCheck
    def initialize(options={})
      @client = options[:client]
      raise ArgumentError.new(":client not specified") unless @client
      @host = @client.uri
      @alias = options[:alias] || @host
    end
    
    def call(status)
      if ping
        status.ok("service active")
        status.info("numDocs: #{luke['numDocs']}")
        status.info("lastModified: #{luke['lastModified']}")
        registry.each do |name, text|
          status.info("#{name} - #{text}")
        end
      else
        status.fail("service down")
      end
    end
    
    def luke
      @luke ||= begin
                  @client.luke(:show => 'schema', :numTerms => 0)['index'] 
                rescue
                  {}
                end
    end

    def registry
      @registry ||= begin
                      resp = Blacklight.solr.get 'admin/registry.jsp', :params => { :wt => 'xml' }
                      doc = Nokogiri::XML resp
                      h = {}
                      doc.xpath('/solr/*').each do |node|
                        next if node.name == "solr-info"
                        h[node.name] = node.text
                      end
                      h
                    rescue
                      {}
                    end
    end

    def ping
      @client.head("admin/ping").response[:status] == 200
    rescue
      false
    end
  end
end

