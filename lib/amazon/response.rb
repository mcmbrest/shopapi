module ShopsApi
  class Response
    attr_accessor :response
    attr_accessor :results
    
    def initialize(json_response)
      @response = transform_json_response(json_response)
    end
    
=begin
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
    
    def each
      unless @results.nil?
        if @results.class == Array
          @results.each { |r| yield r }
        else
          yield @results
        end
      end
    end
    
    def size
      if @results.nil?
        return 0
      elsif @results.class == Array
        return @results.size
      else
        return 1
      end
    end
=end
    
    protected
    def transform_json_response(response)    
      if response.class == Hash
        r = Hash.new
        response.keys.each do |k|
          r[k] = transform_json_response(response[k])
        end
        return r
      elsif response.class == Array 
        if response.size == 1  
          return transform_json_response(response[0])
        else
          r = Array.new
          response.each do |a|
            r.push(transform_json_response(a))
          end
          return r
        end
      else
        return response
      end
    end
  
=begin

    # Return true if request is valid.
    def is_valid_request?
      Element.get(@doc, "//IsValid") == "True"
    end
  
    # Return true if response has an error.
    def has_error?
      !(error.nil? || error.empty?)
    end
  
    # Return error message.
    def error
      Element.get(@doc, "//Error/Message")
    end
    
    # Return error code
    def error_code
      Element.get(@doc, "//Error/Code")
    end
    
    # Return an array of Amazon::Element item objects.
    def items
      @items ||= (@doc/"Item").collect { |item| Element.new(item) }
    end
    
    # Return the first item (Amazon::Element)
    def first_item
      items.first
    end
    
    # Return current page no if :item_page option is when initiating the request.
    def item_page
      @item_page ||= Element.get(@doc, "//ItemPage").to_i
    end
  
    # Return total results.
    def total_results
      @total_results ||= Element.get(@doc, "//TotalResults").to_i
    end
    
    # Return total pages.
    def total_pages
      @total_pages ||= Element.get(@doc, "//TotalPages").to_i
    end
  
    def marshal_dump
      @doc.to_s
    end
  
    def marshal_load(xml)
      initialize(xml)
    end


=end
  end
  
end
