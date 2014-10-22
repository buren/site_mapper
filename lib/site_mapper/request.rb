require 'url_resolver' # TODO: Allow users to use any resolver

module SiteMapper
  class Request
    INFO_LINK  = 'https://rubygems.org/gems/site_mapper'
    USER_AGENT = "SiteMapper/#{SiteMapper::VERSION} (+#{INFO_LINK})"

    class << self
      def get_page(url, document_type = :html)
        Nokogiri::HTML(Request.get_response(url).body)
      end

      def get_response(url, resolve = false)
        resolved_url = resolve ? resolve_url(url) : url
        uri          = URI.parse(resolved_url)
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if resolved_url.include?('https://')

        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = USER_AGENT
        http.request(request)
      end

      def resolve_url(url, with_query: true)
        resolved = UrlResolver.resolve(url)
        resolved = remove_query(resolved) unless with_query
        resolved
      end

      def remove_query(url)
        index = url.index('?')
        index.nil? ? url : url[0...index]
      end
    end
  end
end
