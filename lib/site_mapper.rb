require 'uri'
require 'net/http'

require 'site_mapper/request'
require 'site_mapper/crawler'
require 'site_mapper/crawl_url'

module SiteMapper
  def self.map(source)
    Crawler.collect_urls(source)
  end
end
