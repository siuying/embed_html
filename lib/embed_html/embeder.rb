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
    attr_accessor :concurrency
    
    def initialize(url, logger=Logger.new($stdout), concurrency=MAX_CONCURRENCY)
      @logger = logger
      @url = url
      @concurrency = concurrency
    end
    
    def process
      @logger.info "downloading url: #{@url}"
      html = Typhoeus::Request.get(@url.to_s).body
      doc = Hpricot(html)
      
      hydra = Typhoeus::Hydra.new(:max_concurrency => @concurrency)
      doc.search("//img").each do |img|                
        begin
          hydra.queue create_fetch_file_request(img, 'src')
        rescue StandardError => e
          @logger.error "failed download image: #{img['src']} #{e.inspect}"
        end
      end

      doc.search("//script").each do |script|                
        begin
          if script['src']
            hydra.queue create_fetch_file_request(script, 'src')
          end
        rescue StandardError => e
          @logger.error "failed download script: #{script['src']} #{e.inspect}"
        end
      end

      doc.search("//link").each do |link|
        begin
          hydra.queue create_fetch_file_request(link, 'href')
        rescue StandardError => e
          @logger.error "failed download linked resource: #{link['href']} #{e.inspect}"
        end
      end
      
      hydra.run

      @logger.info "done"            
      doc.to_html      
    end
    
    private
    def create_fetch_file_request(element, field)
      file_url = URI.join(@url, element.attributes[field])
      @logger.debug "queue download file: #{file_url}"

      request = Typhoeus::Request.new(file_url.to_s)
      request.on_complete do |response|
        data = response.body
        type = response.headers_hash["Content-Type"]
        if data && type
          data_b64 = Base64.encode64(data)
          element.attributes[field] = "data:#{type};base64,#{data_b64}"
        end  
      end
      return request
    end
    
  end
end