require 'logger'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'base64'
require 'typhoeus'

module EmbedHtml
  class Embeder
    MAX_CONCURRENCY = 5
    
    attr_accessor :url
    attr_accessor :logger
    
    def initialize(url, logger=Logger.new($stdout))
      @logger = logger
      @url = url
    end
    
    def process
      @logger.info "downloading url: #{@url}"
      html = Typhoeus::Request.get(@url.to_s).body
      doc = Hpricot(html)
      
      hydra = Typhoeus::Hydra.new(:max_concurrency => MAX_CONCURRENCY)
      doc.search("//img").each do |img|                
        begin
          image_url = URI.join(@url, img.attributes['src'])
          @logger.debug "queue download image: #{image_url}"

          request = Typhoeus::Request.new(image_url.to_s)
          request.on_complete do |response|
            data = response.body
            type = response.headers_hash["Content-Type"]
            if data && type
              data_b64 = Base64.encode64(data)
              img.attributes['src'] = "data:#{type};base64,#{data_b64}"
            end  
          end
          hydra.queue request
        rescue StandardError => e
          @logger.error "failed downloading image: #{image_url} (#{e.message})"
        end
      end
      hydra.run
      @logger.info "done"            
      doc.to_html      
    end
  end
end