require 'logger'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'base64'
require 'typhoeus'
require 'mime/types'

module EmbedHtml
  class Embeder
    MAX_CONCURRENCY = 5
    
    attr_accessor :url_or_html
    attr_accessor :logger
    attr_accessor :concurrency
    attr_accessor :base_dirname
    
    def initialize(url_or_html, logger=Logger.new($stdout), concurrency=MAX_CONCURRENCY)
      @logger = logger
      @url_or_html = url_or_html
      @concurrency = concurrency
    end
    
    def process
      # @logger.info "downloading url: #{@url_or_html}"
      html = (@url_or_html =~ /$http/) ? Typhoeus::Request.get(@url_or_html.to_s).body : @url_or_html
      doc = Hpricot(html)
      
      hydra = Typhoeus::Hydra.new(:max_concurrency => @concurrency)
      doc.search("//img").each do |img|                
        begin
          if img['src']=~ /^http/
            hydra.queue create_fetch_file_request(img, 'src')
          else
            fetch_file(img, 'src')
          end
        rescue StandardError => e
          @logger.error "failed download image: #{img['src']} #{e.inspect}"
        end
      end

      doc.search("//script").each do |script|                
        begin
          if script['src'] and script['src'] =~ /^http/
            hydra.queue create_fetch_file_request(script, 'src')
          elsif script['src']
            fetch_file(script, 'src')
          end
        rescue StandardError => e
          @logger.error "failed download script: #{script['src']} #{e.inspect}"
        end
      end

      doc.search("//link").each do |link|
        begin
          url = link['href']
          if url =~ /^http/
            hydra.queue create_fetch_file_request(link, 'href')
          else
            fetch_file(link, 'href')
          end
        rescue StandardError => e
          @logger.error "failed download linked resource: #{link['href']} #{e.inspect}"
        end
      end
      
      hydra.run

      # @logger.info "done"            
      doc.to_html      
    end
    
    def process_local
      # @logger.info "downloading url: #{@url_or_html}"
      html = open(@url_or_html).read
      doc = Hpricot(html)

      doc.search("//img").each do |img|                
        begin
          fetch_file(img, 'src')
        rescue StandardError => e
          @logger.error "failed download image: #{img['src']} #{e.inspect}"
        end
      end

      doc.search("//script").each do |script|                
        begin
          fetch_file(script, 'src')
        rescue StandardError => e
          @logger.error "failed download script: #{script['src']} #{e.inspect}"
        end
      end

      doc.search("//link").each do |link|
        begin
          fetch_file(link, 'href')
        rescue StandardError => e
          @logger.error "failed download linked resource: #{link['href']} #{e.inspect}"
        end
      end

      # @logger.info "done"            
      doc.to_html      
    end
    
    private
    def create_fetch_file_request(element, field)
      file_url = (@url_or_html =~ /^http/) ? URI.join(@url_or_html, element.attributes[field]) : element.attributes[field]
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

    def fetch_file(element, field)
      file_url = @base_dirname ? "#{@base_dirname.to_s}/#{element.attributes[field]}" : element.attributes[field]
      @logger.debug "queue download file: #{file_url}"
      return unless File.exists?(file_url)
      
      type = MIME::Types.type_for(file_url).first.to_s rescue "application/data"
      data = open(file_url.to_s).read
      if data && type
        data_b64 = Base64.encode64(data)
        element.attributes[field] = "data:#{type};base64,#{data_b64}"
      end  
    end
  end
end