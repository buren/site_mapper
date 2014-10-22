require 'url_resolver' # TODO: Allow users to use any resolver

module SiteMapper
  # Get webpage wrapper.
  class Request
    INFO_LINK  = 'https://rubygems.org/gems/site_mapper'
    USER_AGENT = "SiteMapper/#{SiteMapper::VERSION} (+#{INFO_LINK})"

    class << self
      # Given an URL get it then parse it with Nokogiri::HTML.
      # @return [Nokogiri::HTML] a nokogiri HTML object
      def get_page(url)
        Nokogiri::HTML(Request.get_response_body(url))
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

      # Get response body, rescues with nil if an exception is raised
      # @see #get_response
      def get_response_body(*args)
        get_response(*args).body rescue nil
      end

      # Resolve an URL string and follows redirects
      # if the URL can't be resolved the original URL is returned.
      # @return [String] a URL string that potentially is a redirected URL
      # @example Resolve google.com
      #    resolve_url('google.com')
      #    # => 'https://www.google.com'
      def resolve_url(url, with_query: true)
        resolved = UrlResolver.resolve(url)
        resolved = remove_query(resolved) unless with_query
        resolved
      end

      # Removes query string from URL string.
      # @return [String] an URL string without query
      # @example Removes query string
      #    remove_query('example.com/path?q=keyword')
      #    # => 'example.com/path'
      def remove_query(url)
        index = url.index('?')
        index.nil? ? url : url[0...index]
      end
    end
  end
end
