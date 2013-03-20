module ShopApi
  class Mws < ShopApi::Amazon
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def bild_request(opts)
      opts = self.class.options.merge(opts) if self.class.options
      
      # Include other required options
      opts[:Timestamp] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      opts[:Version] = "2011-10-01"
      opts[:SignatureVersion] = "2"
      opts[:SignatureMethod] = "HmacSHA256"
      opts.delete(:AssociateTag)
      
      url = 'https://mws.amazonservices.com/Products/2011-10-01'

      request_url = prepare_url(opts, url)
      
      return request_url 
    end
    
    def validate_request(opts) 
      raise ShopApi::RequestError, "" if opts[:AssociateTag]
    end
    
  end
end
