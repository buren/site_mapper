module SiteMapper
  # Crawl URL formatter.
  class CrawlUrl
    attr_reader :resolved_base_url, :base_hostname

    # Too many request error message
    TOO_MANY_REQUEST_MSG = "You're being challenged with a 'too many requests' captcha"

    # Initialize CrawlUrl
    # @param [String] base_url
    # @example Intitialize CrawlUrl with example.com as base_url
    #   CrawlUrl.new('example.com')
    def initialize(base_url)
      uri      = URI.parse(Request.resolve_url(base_url))
      host     = uri.hostname
      protocol = uri.port == 443 ? 'https://' : 'http://'
      @resolved_base_url = "#{protocol}#{host}"
      @base_hostname     = URI.parse(@resolved_base_url).hostname
    end

    # Given a link it constructs the absolute path,
    # if valid URL & URL has same domain as @resolved_base_url.
    # @param [String] raw_url url found on page
    # @param [String] get_url current page url
    # @return [String] with absolute path to resource
    # @example Construct absolute URL for '/path', example.com
    #   cu = CrawlUrl.new('example.com')
    #   cu.absolute_url_from('/path', 'example.com/some/path')
    #   # => http://example.com/some/path
    def absolute_url_from(raw_url, get_url)
      return unless eligible_url?(raw_url)
      parsed_url = URI.parse(raw_url) rescue false
      if parsed_url && parsed_url.relative?
        url_from_relative(raw_url, get_url)
      elsif parsed_url && same_domain?(raw_url, @resolved_base_url)
        raw_url
      else
        nil
      end
    end

    private

    def url_from_relative(url, current_page_url)
      if url.start_with?('/')
        "#{without_path_suffix(resolved_base_url)}#{url}"
      elsif url.start_with?('../')
        "#{url_from_dotted_url(url, current_page_url)}"
      else
        "#{with_path_suffix(resolved_base_url)}#{url}"
      end
    end

    def url_from_dotted_url(url, current_page_url)
      absolute_url = with_path_suffix(current_page_url.dup)
      found_dots   = without_path_suffix(url).scan('../').length
      removed_dots = 0
      max_levels   = 4
      while found_dots >= removed_dots && max_levels > removed_dots
        index = absolute_url.rindex('/') or break
        absolute_url = absolute_url[0..(index - 1)]
        removed_dots += 1
      end
      "#{with_path_suffix(absolute_url)}#{url.gsub('../', '')}"
    end

    def with_path_suffix(passed_url)
      url = passed_url.dup
      url.end_with?('/') ? url : url << '/'
    end

    def without_path_suffix(passed_url)
      url = passed_url.dup
      url.end_with?('/') ? url[0...(url.length - 1)] : url
    end

    def eligible_url?(href)
      return false if href.nil? || href.empty?
      dont_start   = %w(javascript: callto: mailto: tel: skype: facetime: wtai: #)
      dont_include = %w(/email-protection#)
      err_include  = %w(/sorry/IndexRedirect?)
      dont_end     = %w(.zip .rar .pdf .exe .dmg .pkg .dpkg .bat)

      err_include.each  { |pattern| fail TOO_MANY_REQUEST_MSG if href.include?(pattern) }
      dont_start.each   { |pattern| return false if href.start_with?(pattern) }      
      dont_include.each { |pattern| return false if href.include?(pattern) }
      dont_end.each     { |pattern| return false if href.end_with?(pattern) }
      true
    end

    def same_domain?(first, second)
      first.include?(second)
    end
  end
end
