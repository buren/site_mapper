# Based on: https://rubygems.org/gems/robots, v0.10.1
module SiteMapper
  # Provided a base URL it checks whether a given URL is
  # allowed to be crawled according to /robots.txt
  # @see https://rubygems.org/gems/robots
  class Robots
    # Parses robots.txt
    class ParsedRobots
      def initialize(body, user_agent)
        @other     = {}
        @disallows = {}
        @allows    = {}
        @delays    = {}
        parse(body)
      end

      # Parse robots.txt body.
      def parse(body)
        agent = /.*/
        body  = body || "User-agent: *\nAllow: /\n"
        body  = body.downcase
        body.each_line.each do |line|
          next if line =~ /^\s*(#.*|$)/
          arr   = line.split(':')
          key   = arr.shift
          value = arr.join(':').strip
          value.strip!
          case key
          when 'user-agent'
            agent = to_regex(value)
          when 'allow'
            @allows[agent] ||= []
            @allows[agent] << to_regex(value)
          when 'disallow'
            @disallows[agent] ||= []
            @disallows[agent] << to_regex(value)
          when 'crawl-delay'
            @delays[agent] = value.to_i
          else
            @other[key] ||= []
            @other[key] << value
          end
        end
        @parsed = true
      end
      
      # @return [Boolean] true if uri is allowed to be crawled
      # @example Check if http://www.google.com/googlesites is allowed to be crawled
      #    uri = URI.parse('http://www.google.com/googlesites')
      #    robots.allowed?(uri, 'SiteMapper') # => false (as of 2014-10-22)
      def allowed?(uri, user_agent)
        return true unless @parsed
        allowed = true
        path    = uri.request_uri
        
        @disallows.each do |key, value|
          if user_agent =~ key
            value.each do |rule|
              if path =~ rule
                allowed = false
              end
            end
          end
        end
        
        @allows.each do |key, value|
          unless allowed      
            if user_agent =~ key
              value.each do |rule|
                if path =~ rule
                  allowed = true
                end
              end
            end
          end
        end
        allowed
      end
      
      # @return [Hash] key/value pairs from robots.txt
      def other_values
        @other
      end
        
      protected
      
      def to_regex(pattern)
        return /should-not-match-anything-123456789/ if pattern.strip.empty?
        pattern = Regexp.escape(pattern)
        pattern.gsub!(Regexp.escape('*'), '.*')
        Regexp.compile("^#{pattern}")
      end
    end

    def initialize(url, user_agent)
      @user_agent = user_agent
      @parsed     = {}
      @robots_txt = Request.get_response_body("#{url}/robots.txt", true)
    end
    
    # @return [Boolean] true if uri is allowed to be crawled
    # @example Check if http://www.google.com/googlesites is allowed to be crawled
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.allowed?('http://www.google.com/googlesites') # => false (as of 2014-10-22)
    def allowed?(uri)
      uri  = to_uri(uri)
      host = uri.host
      @parsed[host] ||= ParsedRobots.new(@robots_txt, @user_agent)
      @parsed[host].allowed?(uri, @user_agent)
    rescue
      true
    end

    # @return [Array] array of sitemaps defined in robots.txt
    # @example Get sitemap for google.com
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.sitemaps
    def sitemaps
      uri    = to_uri(uri)
      values = other_values(uri.host)
      values['sitemap'] or []
    rescue
      []
    end
    
    # @return [Hash] key/value pairs from robots.txt
    # @example Get other values for google.com
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.other_values
    def other_values(uri)
      uri  = to_uri(uri)
      host = uri.host
      @parsed[host] ||= ParsedRobots.new(@robots_txt, @user_agent)
      @parsed[host].other_values
    end

    private 
    
    def to_uri(uri)
      uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
      uri
    end
  end
end