module SiteMapper
  # Based on: https://rubygems.org/gems/robots, v0.10.1
  # Provided a base URL it checks whether a given URL is
  # allowed to be crawled according to /robots.txt.
  # @see https://rubygems.org/gems/robots
  class Robots
    # Parses robots.txt
    class ParsedRobots
      # Initializes ParsedRobots
      def initialize(body, user_agent)
        @other     = {}
        @disallows = {}
        @allows    = {}
        @delays    = {}
        @sitemaps  = []
        parse(body)
      end

      # Parse robots.txt body.
      # @param [String] body the webpage body HTML
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
          when 'sitemap'
            @sitemaps << value
          else
            @other[key] ||= []
            @other[key] << value
          end
        end
        @parsed = true
      end

      # @param [URI] uri to be checked
      # @param [String] user_agent to be checked
      # @return [Boolean] true if uri is allowed to be crawled
      # @example Check if http://www.google.com/googlesites is allowed to be crawled
      #    uri = URI.parse('http://www.google.com/googlesites')
      #    robots.allowed?(uri, 'SiteMapper')
      #    # => false (as of 2014-10-22)
      def allowed?(uri, user_agent)
        return true unless @parsed
        allowed = true
        path    = uri.request_uri

        user_agent.downcase!

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

      # @param [String] user_agent
      # @return [Integer] crawl delay for user_agent
      def crawl_delay(user_agent)
        agent = user_agent.dup
        agent = to_regex(agent.downcase) if user_agent.is_a?(String)
        @delays[agent]
      end

      # Return key/value paris with unknown meaning.
      # @return [Hash] key/value pairs from robots.txt
      def other_values
        @other
      end

      # @return [Array] returns sitemaps defined in robots.txt
      def sitemaps
        @sitemaps
      end

      protected

      # @return [Regex] regex from pattern
      # @param [String] pattern to compile to Regex
      def to_regex(pattern)
        return /should-not-match-anything-123456789/ if pattern.strip.empty?
        pattern = Regexp.escape(pattern)
        pattern.gsub!(Regexp.escape('*'), '.*')
        Regexp.compile("^#{pattern}")
      end
    end

    # @param [String] robots_txt contents of /robots.txt
    # @param [String] hostname for the passed robots_txt
    # @param [String] user_agent to check
    def initialize(robots_txt, hostname, user_agent)
      @robots_txt = robots_txt
      @hostname   = hostname
      @user_agent = user_agent
      @parsed     = {}
    end

    # @param [String, URI] uri String or URI to check
    # @return [Boolean] true if uri is allowed to be crawled
    # @example Check if http://www.google.com/googlesites is allowed to be crawled
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.allowed?('http://www.google.com/googlesites') # => false (as of 2014-10-22)
    def allowed?(uri)
      uri  = to_uri(uri)
      host = uri.host
      @parsed[host] ||= ParsedRobots.new(@robots_txt, @user_agent)
      @parsed[host].allowed?(uri, @user_agent)
    end

    # @return [Array] array of sitemaps defined in robots.txt
    # @example Get sitemap for google.com
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.sitemaps
    def sitemaps
      host = @hostname
      @parsed[host] ||= ParsedRobots.new(@robots_txt, @user_agent)
      @parsed[host].sitemaps
    end

    # @param [String, URI] uri String or URI get other_values from
    # @return [Hash] key/value pairs from robots.txt
    # @example Get other values for google.com
    #    robots = Robots.new('google.com', 'SiteMapper')
    #    robots.other_values
    def other_values
      host = @hostname
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