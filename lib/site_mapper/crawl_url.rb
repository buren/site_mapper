module SiteMapper
  # Crawl URL formatter.
  class CrawlUrl
    attr_reader :resolved_base_url

    # Too many request error message
    TOO_MANY_REQUEST_MSG = "You're being challenged with a 'too many requests' captcha"

    # Initialize CrawlUrl
    # @param [String] base_url
    # @example Intitialize CrawlUrl with example.com as base_url
    #   CrawlUrl.new('example.com')
    def initialize(base_url)
      @resolved_base_url = Request.resolve_url(base_url) # "#{protocol}#{host}"
      @base_hostname     = URI.parse(@resolved_base_url).hostname
    end

    # Given a link it constructs the absolute path,
    # if valid URL & URL has same domain as @resolved_base_url.
    # @param [String] page_url url found on page
    # @param [String] current_url current page url
    # @return [String] with absolute path to resource
    # @example Construct absolute URL for '/path', example.com
    #   cu = CrawlUrl.new('example.com')
    #   cu.absolute_url_from('/path', 'example.com/some/path')
    #   # => http://example.com/some/path
    def absolute_url_from(page_url, current_url)
      return unless eligible_url?(page_url)
      parsed_uri = URI.join(current_url, page_url) rescue return
      return unless parsed_uri.hostname == @base_hostname
      parsed_uri.to_s
    end

    private

    def eligible_url?(href)
      return false if href.nil? || href.empty?
      dont_start   = %w(javascript: callto: mailto: tel: skype: facetime: wtai: #)
      dont_include = %w(/email-protection#)
      err_include  = %w(/sorry/IndexRedirect?)
      dont_end     = %w(.zip .rar .json .pdf .exe .dmg .pkg .dpkg .bat)

      err_include.each  { |pattern| fail TOO_MANY_REQUEST_MSG if href.include?(pattern) }
      dont_start.each   { |pattern| return false if href.start_with?(pattern) }      
      dont_include.each { |pattern| return false if href.include?(pattern) }
      dont_end.each     { |pattern| return false if href.end_with?(pattern) }
      true
    end
  end
end
