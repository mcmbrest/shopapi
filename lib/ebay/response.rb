module ShopApi
  class Response
    attr_accessor :response, :results
    
    def initialize(json_response)
      @response = json_response
    end
    
    def success?
      @response["Ack"] == 'Success' || @response['ack'] == 'Success'
    end
    
    def failure?
      @response["Ack"] == 'Failure' || @response['ack'] == 'Failure'
    end
    
    def trim(key)
      if @response.has_key?(key.to_s)
        @response = @response[key.to_s]
      end
    end


    # Return true if request is valid.
    def is_valid_request?
      @response.response.any?{|k,v| v.class == Hash && v.has_key?('Request') && v['Request']['IsValid'] == "True"}
    end

    # Return true if response has an error.
    def has_error?
      !(error.blank?)
    end

    # Return error message.
    def error
      e = @response.response.select{|k,v| v.class == Hash && v.has_key?('Request') && v['Request'].has_key?('Errors')}
      e = e[e.keys[0]]['Request']['Errors']['Error']['Message'] if !e.blank?
    end     

  end
end
