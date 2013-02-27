module ShopApi
  class Ecs < ShopApi::Amazon
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    def item_search(opts = {})
      opts[:Operation] = 'ItemSearch'
      opts[:SearchIndex] ||= 'All'
      
      response = get_response(bild_request(opts))
      response.trim(:ItemSearchResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end

    # Search an item by ASIN no.
    def item_lookup(opts = {})
      raise ArgumentError unless opts[:ItemId]
      opts[:Operation] = 'ItemLookup'
      
      response = get_response(bild_request(opts))
      response.trim(:ItemLookupResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end    

    # Search a browse node by BrowseNodeId
    def browse_node_lookup(opts = {})
      raise ArgumentError unless opts[:BrowseNodeId]
      opts[:Operation] = 'BrowseNodeLookup'
      
      response = get_response(bild_request(opts))
      response.trim(:BrowseNodeLookupResponse)
      if response.response.has_key?('BrowseNodes') && response.response['BrowseNodes'].has_key?('BrowseNode')
        response.results = response.response['BrowseNodes']['BrowseNode']
      end
      return response
    end    

    # Search a similar items node by ItemId
    def similarity_lookup(opts = {})
      raise ArgumentError unless opts[:ItemId]
      opts[:Operation] = 'SimilarityLookup'
      
      response = get_response(bild_request(opts))
      response.trim(:SimilarityLookupResponse)
      if response.response.has_key?('Items') && response.response['Items'].has_key?('Item')
        response.results = response.response['Items']['Item']
      end
      return response
    end    

    # Create remote cart
    def cart_create(opts = {})
      opts[:Operation] = 'CartCreate'
      
      response = get_response(bild_request(opts))
      response.trim(:CartCreateResponse)
      if response.response.has_key?('Cart') && response.response['Cart'].has_key?('CartItems') && response.response['Cart']['CartItems'].has_key?('CartItem')
        response.results = response.response['Cart']['CartItems']['CartItem']
      end
      return response
    end    

    # Add items by ASIN on OfferListingID to remote cart
    def cart_add(opts = {})
      raise ArgumentError unless opts[:CartId] && opts[:HMAC]
      opts[:Operation] = 'CartAdd'
      
      response = get_response(bild_request(opts))
      response.trim(:CartAddResponse)
      if response.response.has_key?('Cart') && response.response['Cart'].has_key?('CartItems') && response.response['Cart']['CartItems'].has_key?('CartItem')
        response.results = response.response['Cart']['CartItems']['CartItem']
      end
      return response
    end    

    # Modify quantity items by CartItemID in remote cart
    def cart_modify(opts = {})
      raise ArgumentError unless opts[:CartId] && opts[:HMAC]
      opts[:Operation] = 'CartModify'
      
      response = get_response(bild_request(opts))
      response.trim(:CartModifyResponse)
      if response.response.has_key?('Cart') && response.response['Cart'].has_key?('CartItems') && response.response['Cart']['CartItems'].has_key?('CartItem')
        response.results = response.response['Cart']['CartItems']['CartItem']
      end
      return response
    end    

    # Get all items in remote cart
    def cart_get(opts = {})
      raise ArgumentError unless opts[:CartId] && opts[:HMAC]
      opts[:Operation] = 'CartGet'
      
      response = get_response(bild_request(opts))
      response.trim(:CartGetResponse)
      if response.response.has_key?('Cart') && response.response['Cart'].has_key?('CartItems') && response.response['Cart']['CartItems'].has_key?('CartItem')
        response.results = response.response['Cart']['CartItems']['CartItem']
      end
      return response
    end    

    # Clear remote cart
    def cart_clear(opts = {})
      raise ArgumentError unless opts[:CartId] && opts[:HMAC]
      opts[:Operation] = 'CartClear'
      
      response = get_response(bild_request(opts))
      response.trim(:CartClearResponse)
      if response.response.has_key?('Cart')
        response.results = response.response['Cart']
      end
      return response
    end    
    
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def bild_request(opts)
      opts = self.class.options.merge(opts) if self.class.options
      
      # Include other required options
      opts[:Timestamp] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      request_url = prepare_url(opts)
      
      return request_url 
    end
    
    def validate_request(opts) 
      raise ShopApi::RequestError, "" if opts[:AssociateTag]
    end
    
  end
end
