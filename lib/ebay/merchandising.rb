module ShopApi
  class Merchandising < ShopApi::Ebay
    def self.base_url_suffix
      "ebay.com/MerchandisingService"
    end
    
    VERSION = '1.5.0'
    
    #generate request url
    def get_url(service=nil, params)
      return build_request_url((service.nil? ? 'getSimilarItems' : service), params)
    end
    
    #http://developer.ebay.com/DevZone/merchandising/docs/CallRef/getMostWatchedItems.html
    def get_most_watched_items(params)
      raise ArgumentError unless params[:categoryId]
      response = get_json_response(build_request_url('getMostWatchedItems', params))
      response.trim(:getMostWatchedItemsResponse)
      if response.response.has_key?('itemRecommendations')
        response.results = response.response['itemRecommendations']
      end
      return response
    end
  
    #http://developer.ebay.com/DevZone/merchandising/docs/CallRef/getRelatedCategoryItems.html
    def get_related_category_items(params)
      raise ArgumentError unless params[:categoryId] or params[:itemId]
      response = get_json_response(build_request_url('getRelatedCategoryItems', params))
      response.trim(:getRelatedCategoryItemsResponse)
      if response.response.has_key?('itemRecommendations')
        response.results = response.response['itemRecommendations']
      end
      return response
    end
  
    #http://developer.ebay.com/DevZone/merchandising/docs/CallRef/getSimilarItems.html
    def get_similar_items(params)
      raise ArgumentError unless params[:categoryId] or params[:itemId]
      response = get_json_response(build_request_url('getSimilarItems', params))
      response.trim(:getSimilarItemsResponse)
      if response.response.has_key?('itemRecommendations')
        response.results = response.response['itemRecommendations']
      end
      return response
    end
  
    #http://developer.ebay.com/DevZone/merchandising/docs/CallRef/getTopSellingProducts.html
    def get_top_selling_products(params)
      response = get_json_response(build_request_url('getTopSellingProducts', params))
      response.trim(:getTopSellingProductsResponse)
      if response.response.has_key?('productRecommendations')
        response.results = response.response['productRecommendations']
      end
      return response
    end
  
    #http://developer.ebay.com/DevZone/merchandising/docs/CallRef/getVersion.html
    def get_version
      response = get_json_response(build_request_url('getVersion'))
      response.trim(:getVersionResponse)
      if response.response.has_key?('version')
        response.results = response.response['version']
      end
      return response
    end
    
    private    
    def build_request_url(service, params=nil)
      url = "#{self.class.base_url}?OPERATION-NAME=#{service}&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=#{VERSION}&CONSUMER-ID=#{ShopApi::Ebay.app_id}&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD"
      url += build_rest_payload(params)
      return url
    end
  end
end
