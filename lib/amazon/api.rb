require 'net/http'
require 'json'
require 'uri'

require 'hmac-sha2'
require 'base64'
require 'openssl' 

module ShopsApi
  class RequestError < StandardError; end
  
  class Ecs
    VERSION = '2.2.4'
    
    SERVICE_URLS = {
        :us => 'http://ecs.amazonaws.com/onca/xml',
    }
    
    OPENSSL_DIGEST_SUPPORT = OpenSSL::Digest.constants.include?( 'SHA256' ) ||
                             OpenSSL::Digest.constants.include?( :SHA256 )
    
    OPENSSL_DIGEST = OpenSSL::Digest::Digest.new( 'sha256' ) if OPENSSL_DIGEST_SUPPORT
    
    @@options = {
      :version => "2011-08-01",
      :service => "AWSECommerceService"
    }
    
    @@debug = false

    # Default search options
    def self.options
      @@options
    end
    
    # Set default search options
    def self.options=(opts)
      @@options = opts
    end
    
    # Get debug flag.
    def self.debug
      @@debug
    end
    
    # Set debug flag to true or false.
    def self.debug=(dbg)
      @@debug = dbg
    end
    
    def self.configure(&proc)
      raise ArgumentError, "Block is required." unless block_given?
      yield @@options
    end
    
    protected
      def self.log(s)
        return unless self.debug
        if defined? RAILS_DEFAULT_LOGGER
          RAILS_DEFAULT_LOGGER.error(s)
        elsif defined? LOGGER
          LOGGER.error(s)
        else
          puts s
        end
      end
      
    private 
      def self.prepare_url(opts)
        country = opts.delete(:country)
        country = (country.nil?) ? 'us' : country
        request_url = SERVICE_URLS[country.to_sym]
        raise Amazon::RequestError, "Invalid country '#{country}'" unless request_url

        secret_key = opts.delete(:AWS_secret_key)
        request_host = URI.parse(request_url).host
        
        qs = ''
        
        opts = opts.collect do |a,b| 
          [camelize(a.to_s), b.to_s] 
        end
        
        opts = opts.sort do |c,d| 
          c[0].to_s <=> d[0].to_s
        end
        
        opts.each do |e| 
          log "Adding #{e[0]}=#{e[1]}"
          next unless e[1]
          e[1] = e[1].join(',') if e[1].is_a? Array
          # v = URI.encode(e[1].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
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
      
      def self.url_encode(string)
        string.gsub( /([^a-zA-Z0-9_.~-]+)/ ) do
          '%' + $1.unpack( 'H2' * $1.bytesize ).join( '%' ).upcase
        end
      end
      
      def self.camelize(s)
        s.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      end
      
      def self.sign_request(url, key)
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
