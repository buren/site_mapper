require 'set'
require 'nokogiri'

module SiteMapper
  # Crawls a given site.
  class Crawler
    # @param [String] url base url for crawler
    # @param [Hash] options hash, resolve key (optional false by default)
    def initialize(url, options = {})
      @base_url    = Request.resolve_url(url)
      @options     = { resolve: false }.merge(options)
      @crawl_url   = CrawlUrl.new(@base_url)
      @fetch_queue = CrawlQueue.new
      @processed   = Set.new
      @robots      = nil
    end

    # @see #collect_urls
    def self.collect_urls(base_url)
      new(base_url).collect_urls { |url| yield(url) }
    end

    # Collects all links on domain for domain.
    # @return [Array] with links.
    # @example URLs for example.com
    #   crawler = Crawler.new('example.com')
    #   crawler.collect_urls
    # @example URLs for example.com with block (executes in its own thread)
    #   crawler = Crawler.new('example.com')
    #   crawler.collect_urls do |new_url|
    #     puts "New URL found: #{new_url}"
    #   end
    def collect_urls
      @fetch_queue << @crawl_url.resolved_base_url
      until @fetch_queue.empty?
        url = @fetch_queue.pop
        yield(url)
        page_links(url)
      end
      Logger.log "Crawling finished, #{@processed.length} links found"
      @processed.to_a
    rescue Interrupt, IRB::Abort
      Logger.err_log 'Crawl interrupted.'
      @fetch_queue.to_a
    end

    private

    def page_links(get_url)
      Logger.log "Queue length: #{@fetch_queue.length}, Parsing: #{get_url}"
      link_elements = Request.get_page(get_url).css('a') rescue []
      @processed << get_url
      link_elements.each do |page_link|
        url = @crawl_url.absolute_url_from(page_link.attr('href'), get_url)
        @fetch_queue << url if url && eligible_for_queue?(resolve(url))
      end
    end

    def eligible_for_queue?(url)
      robots.allowed?(url) && !@processed.include?(url)
    end

    def robots
      return @robots unless @robots.nil?
      robots_body  = Request.get_response_body("#{@base_url}/robots.txt")
      @robots      = Robots.new(robots_body, URI.parse(@base_url).host, SiteMapper::USER_AGENT)
      @robots
    end

    def resolve(url)
      @options[:resolve] ? Request.resolve_url(url) : url
    end

    # Queue of urls to be crawled.
    class CrawlQueue
      # @return [Set] that exends EnumerablePop module
      def self.new
        Set.new.extend(EnumerablePop)
      end
      
      # Add pop method when added to class.
      # The class that extends this module need to implement #first and #delete.
      module EnumerablePop
        # Pop first element from list.
        # @return [Object] the first object in the list or nil
        def pop
          first_element = first
          delete(first_element)
          first_element
        end
      end
    end
  end  
end
