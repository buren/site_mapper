require 'spec_helper'

def make_robot(name, user_agent = 'SiteMapper')
  robot_body = File.read("spec/fixtures/#{name}.txt")
  SiteMapper::Robots::ParsedRobots.new(robot_body, user_agent)
end

def make_uri(name, relative_path = '')
  URI.parse("http://#{name}.com#{relative_path}")
end

describe SiteMapper::Robots do
  let(:robots) do
    robots_txt = File.read('spec/fixtures/google.txt')
    SiteMapper::Robots.new(robots_txt, 'google.com', 'SiteMapper')
  end

  describe '#allowed?' do
    it 'returns false if url is allowed' do
      expect(robots.allowed?('http://www.google.com/')).to eq true
      expect(robots.allowed?('http://www.google.com/news/directory')).to eq true
    end

    it 'returns false if url is disallowed' do
      expect(robots.allowed?('http://www.google.com/googlesites')).to eq false
    end
  end
  
  it '#sitemaps' do
    expect(robots.sitemaps.length).to eq 6
  end

  it '#other_values' do
    expect(robots.other_values).to eq({})
  end

  describe 'ParsedRobots' do 
    let(:user_agent) { 'SiteMapper'}

    let(:empty_robots)      { make_robot('emptyish')   }
    let(:eventbrite_robots) { make_robot('eventbrite') }
    let(:google_robots)     { make_robot('google')     }
    let(:yelp_robots)       { make_robot('yelp')       }
    
    describe '#allowed?' do 
      it 'returns true for allowed urls' do
        expect(google_robots.allowed?(make_uri(:google), user_agent)).to eq true
        expect(google_robots.allowed?(make_uri(:google, '/news/directory'), user_agent)).to eq true
        expect(yelp_robots.allowed?(make_uri(:yelp, '/'), user_agent)).to eq true
        expect(eventbrite_robots.allowed?(make_uri(:eventbrite, '/'), user_agent)).to eq true
      end

      it 'returns false for all disallowed urls' do
        expect(google_robots.allowed?(make_uri(:google, '/googlesite'), user_agent)).to eq false
        expect(yelp_robots.allowed?(make_uri(:yelp, '/advertise?'), user_agent)).to eq false
        expect(yelp_robots.allowed?(make_uri(:yelp, '/'), 'fasterfox')).to eq false
        expect(yelp_robots.allowed?(make_uri(:yelp, '/'), 'Fasterfox')).to eq false
      end

      it 'respects User-agent rules' do
        expect(eventbrite_robots.allowed?(make_uri(:eventbrite, '/'), 'Balihoo')).to eq false
      end

      it 'returns true if empty body' do
        [
          make_uri(:google),
          make_uri(:example),
          make_uri(:example, '/somepath')
        ].each { |uri| expect(empty_robots.allowed?(uri, user_agent)).to eq true }
      end
    end

    describe '#other_values' do
      it 'returns other values' do
        expect(empty_robots.other_values).to eq({"other-key"=>["4"]})
      end
    end

    describe '#crawl_delay' do
      it 'returns crawl_delay for given user_agent' do
        expect(eventbrite_robots.crawl_delay(/^msnbot/)).to eq 4
        expect(eventbrite_robots.crawl_delay('msnbot')).to eq 4
        expect(eventbrite_robots.crawl_delay('slurp')).to eq 4
      end
    end

    describe '#sitemaps' do 
      it 'returns sitemaps defined in robots.txt' do
        sitemaps = google_robots.sitemaps
        expect(sitemaps.first).to eq 'http://www.gstatic.com/s2/sitemaps/profiles-sitemap.xml'
        expect(sitemaps.length).to eq 6
      end

      it 'empty if no sitemaps are defiend in robots.txt' do
        sitemaps = empty_robots.sitemaps
        expect(sitemaps.empty?).to eq true
      end
    end
  end
end
