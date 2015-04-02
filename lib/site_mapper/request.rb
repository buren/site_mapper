require 'url_resolver' # TODO: Allow users to use any resolver

module SiteMapper
  # Get webpage wrapper.
  class Request
    # Request info link
    INFO_LINK  = 'https://rubygems.org/gems/site_mapper'
    # Request User-Agent
    USER_AGENT = "SiteMapper/#{SiteMapper::VERSION} (+#{INFO_LINK})"

    class << self
      # Given an URL get it then parse it with Nokogiri::HTML.
      # @param [String] url
      # @param [Hash] options
      # @return [Nokogiri::HTML] a nokogiri HTML object
      def document(url, options = {})
        Nokogiri::HTML(Request.response_body(url, options))
      end

      # Given an URL get the response.
      # @param [String] url
      # @param [Hash] options
      # @return [Net::HTTPOK] if response is successfull, raises error otherwise
      # @example get example.com and resolve the URL
      #    Request.response('example.com', resolve: true)
      # @example get example.com and do *not* resolve the URL
      #    Request.response('http://example.com')
      # @example get example.com and resolve the URL
      #    Request.response('http://example.com', resolve: true)
      # @example get example.com and resolve the URL and use a custom User-Agent
      #    Request.response('http://example.com', resolve: true, user_agent: 'MyUserAgent')
      def response(url, options = {})
        options = {
          resolve: false,
          user_agent: SiteMapper::USER_AGENT
        }.merge(options)
        resolved_url = options[:resolve] ? resolve_url(url) : url
        uri          = URI.parse(resolved_url)
        http         = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if resolved_url.start_with?('https://')

        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = options[:user_agent]
        http.request(request)
      end

      # Get response body, rescues with nil if an exception is raised.
      # @see Request#response
      def response_body(*args)
        response(*args).body
      end

      # Resolve an URL string and follows redirects.
      # if the URL can't be resolved the original URL is returned.
      # @param [String] url to resolve
      # @return [String] a URL string that potentially is a redirected URL
      # @example Resolve google.com
      #    resolve_url('google.com')
      #    # => 'https://www.google.com'
      def resolve_url(url)
        resolved = UrlResolver.resolve(url)
        resolved = resolved.prepend('http://') unless has_protocol?(resolved)
        resolved
      end

      private

      def has_protocol?(url)
        url.start_with?('https://') || url.start_with?('http://')
      end
    end
  end
end
