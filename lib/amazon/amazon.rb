module ShopsApi
  class Amazon < ShopsApi::Ecs
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    def self.item_search(terms, opts = {})
      opts[:operation] = 'ItemSearch'
      opts[:search_index] = opts[:search_index] || 'Books'
      
      type = opts.delete(:type)
      if type 
        opts[type.to_sym] = terms
      else 
        opts[:keywords] = terms
      end
      
      self.send_request(opts)
    end

    # Search an item by ASIN no.
    def self.item_lookup(item_id, opts = {})
      opts[:operation] = 'ItemLookup'
      opts[:item_id] = item_id
      
      self.send_request(opts)
    end    

    # Search a browse node by BrowseNodeId
    def self.browse_node_lookup(browse_node_id, opts = {})
      opts[:operation] = 'BrowseNodeLookup'
      opts[:browse_node_id] = browse_node_id
      
      self.send_request(opts)
    end    
    
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts = self.options.merge(opts) if self.options
      
      # Include other required options
      opts[:timestamp] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"
      
      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise ShopsApi::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      res = JSON.parse(Hash.from_xml(res.body).to_json)
      Response.new(res)
    end
    
    def self.validate_request(opts) 
      raise ShopsApi::RequestError, "" if opts[:associate_tag]
    end
    
  end
end
