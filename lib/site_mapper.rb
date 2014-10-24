require 'uri'
require 'net/http'

require 'site_mapper/version'
require 'site_mapper/request'
require 'site_mapper/robots'
require 'site_mapper/crawler'
require 'site_mapper/crawl_url'

# Find all links on domain to domain
module SiteMapper
  # SiteMapper info link
  INFO_LINK  = 'https://rubygems.org/gems/site_mapper'
  # SiteMapper User-Agent
  USER_AGENT = "SiteMapper/#{SiteMapper::VERSION} (+#{INFO_LINK})"

  # Map all links on a given site.
  # @return [Array] with links.
  # @param [String] link to domain
  # @example Collect all URLs from example.com
  #   SiteMapper.map('example.com')
  def self.map(link)
    Crawler.collect_urls(link) { |url| yield(url) if block_given? }
  end
end
