require 'uri'
require 'net/http'

require 'site_mapper/version'
require 'site_mapper/request'
require 'site_mapper/robots'
require 'site_mapper/crawler'
require 'site_mapper/crawl_url'

# Find all links on domain to domain
module SiteMapper
  # Returns all links found on domain to domain.
  # @return [Array] with links.
  # @param [String] link to domain
  # @example Collect all URLs from example.com
  #   SiteMapper.map('example.com')
  def self.map(source)
    Crawler.collect_urls(source) { |url| yield(url) if block_given? }
  end
end
