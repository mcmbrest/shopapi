require 'net/http'
require 'json'
require 'uri'

require 'hmac-sha2'
require 'base64'
require 'openssl' 

module ShopApi
  class RequestError < StandardError; end
  
  class Amazon
    VERSION = '2.2.4'
    
    OPENSSL_DIGEST_SUPPORT = OpenSSL::Digest.constants.include?( 'SHA256' ) ||
                             OpenSSL::Digest.constants.include?( :SHA256 )
    
    OPENSSL_DIGEST = OpenSSL::Digest::Digest.new( 'sha256' ) if OPENSSL_DIGEST_SUPPORT
    
    @@request_options = {
      :version => "2011-08-01",
      :service => "AWSECommerceService"
    }
    
    class << self
      # Default search options
      def options
        @@options
      end
      
      # Set default search options
      def options=(opts)
        @@options = opts
      end
      
      def configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @@options
      end
    end
    
    protected

      def get_response(url)
        res = Net::HTTP.get_response(URI::parse(url))
        unless res.kind_of? Net::HTTPSuccess
          raise ShopApi::RequestError, "HTTP Response: #{res.code} #{res.message}"
        end
        ShopApi::Response.new(JSON.parse(Hash.from_xml(res.body).to_json))
      end
      

      def prepare_url(opts)
        request_url = 'http://ecs.amazonaws.com/onca/xml'

        secret_key = opts.delete(:AWSSecretKey)
        request_host = URI.parse(request_url).host
        
        opts.merge!(@@request_options)
        opts = opts.collect do |a,b| 
          [camelize(a.to_s), b.to_s] 
        end
        
        opts = opts.sort do |c,d| 
          c[0].to_s <=> d[0].to_s
        end
        
        qs = ''
        opts.each do |e| 
          log "Adding #{e[0]}=#{e[1]}"
          next unless e[1]
          e[1] = e[1].join(',') if e[1].is_a? Array
          v = self.url_encode(e[1].to_s)
          qs << "&" unless qs.length == 0
          qs << "#{e[0]}=#{v}"
        end
        
        signature = ''
        unless secret_key.nil?
          request_to_sign="GET\n#{request_host}\n/onca/xml\n#{qs}"
          signature = "&Signature=#{sign_request(request_to_sign, secret_key)}"
        end

        "#{request_url}?#{qs}#{signature}"
      end
      
      def url_encode(string)
        string.gsub( /([^a-zA-Z0-9_.~-]+)/ ) do
          '%' + $1.unpack( 'H2' * $1.bytesize ).join( '%' ).upcase
        end
      end
      
      def camelize(s)
        s.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      end
      
      def sign_request(url, key)
        return nil if key.nil?
        
        if (OPENSSL_DIGEST_SUPPORT)
          signature = OpenSSL::HMAC.digest(OPENSSL_DIGEST, key, url)
          signature = [signature].pack('m').chomp
        else
          signature = Base64.encode64( HMAC::SHA256.digest(key, url) ).strip
        end
        signature = URI.escape(signature, Regexp.new("[+=]"))
        return signature
      end
  end


end
