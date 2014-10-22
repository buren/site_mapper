require 'set'
require 'nokogiri'

module SiteMapper
  class Crawler
    CRAWLER_INFO_LINK = 'https://rubygems.org/gems/wayback_archiver'
    HEADERS_HASH      = {
      'User-Agent' => "SiteMapper/#{SiteMapper::VERSION} (+#{CRAWLER_INFO_LINK})"
    }

    def initialize(url, resolve = false)
      base_url     = Request.resolve_url(url)
      @options     = { resolve: resolve }
      @crawl_url   = CrawlUrl.new(base_url)
      @fetch_queue = CrawlQueue.new
      @processed   = Set.new
    end

    # @see #collect_urls
    def self.collect_urls(base_url)
      new(base_url).collect_urls { |url| yield(url) }
    end

    # Collects all links on domain for domain
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
        Thread.new { yield(url) if block_given? }
        page_links(url)
      end
      puts "Crawling finished, #{@processed.length} links found"
      @processed.to_a
    rescue Interrupt, IRB::Abort
      puts 'Crawl interrupted.'
      @fetch_queue.to_a
    end

    private

    def page_links(get_url)
      puts "Queue length: #{@fetch_queue.length}, Parsing: #{get_url}"
      link_elements = Request.get_page(get_url).css('a') rescue []
      @processed << get_url
      link_elements.each do |page_link|
        absolute_url = @crawl_url.absolute_url_from(page_link.attr('href'), get_url)
        if absolute_url
          url = resolve(absolute_url)
          @fetch_queue << url unless @processed.include?(url)
        end
      end
    end

    def resolve(url)
      @options[:resolve] ? Request.resolve_url(url) : url
    end
  end

  class CrawlQueue
    def self.new
      Set.new.extend(EnumerablePop)
    end
    
    module EnumerablePop
      def pop
        first_element = first
        delete(first_element)
        first_element
      end
    end
  end
end
