module ShopApi
  class Ecs < ShopApi::Amazon
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    def item_search(keywords, opts = {})
      opts[:operation] = 'ItemSearch'
      opts[:search_index] ||= 'All'
      opts[:keywords] = keywords
      
      response = get_response(bild_request(opts))
      response.trim(:ItemSearchResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end

    # Search an item by ASIN no.
    def item_lookup(item_id, opts = {})
      raise ArgumentError unless item_id
      opts[:operation] = 'ItemLookup'
      opts[:item_id] = item_id
      
      response = get_response(bild_request(opts))
      response.trim(:ItemLookupResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end    

    # Search a browse node by BrowseNodeId
    def browse_node_lookup(browse_node_id, opts = {})
      raise ArgumentError unless browse_node_id
      opts[:operation] = 'BrowseNodeLookup'
      opts[:browse_node_id] = browse_node_id
      
      response = get_response(bild_request(opts))
      response.trim(:BrowseNodeLookupResponse)
      if response.response.has_key?('BrowseNodes') && response.response['BrowseNodes'].has_key?('BrowseNode')
        response.results = response.response['BrowseNodes']['BrowseNode']
      end
      return response
    end    

    # Search a similar items node by ItemId
    def similarity_lookup(item_id, opts = {})
      raise ArgumentError unless item_id
      opts[:operation] = 'SimilarityLookup'
      opts[:item_id] = item_id
      
      response = get_response(bild_request(opts))
      response.trim(:SimilarityLookupResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end    
    
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def bild_request(opts)
      opts = self.class.options.merge(opts) if self.class.options
      
      # Include other required options
      opts[:timestamp] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      opts[:ResponseGroup] = 'Medium'

      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"
      
      return request_url 
    end
    
    def validate_request(opts) 
      raise ShopApi::RequestError, "" if opts[:associate_tag]
    end
    
  end
end
