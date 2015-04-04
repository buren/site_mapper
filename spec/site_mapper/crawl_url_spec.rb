require 'spec_helper'

describe SiteMapper::CrawlUrl do
  let(:crawl_url) { SiteMapper::CrawlUrl.new('example.com') }

  describe '#absolute_url_from' do
    it 'returns nil for urls from different domain' do
      url = crawl_url.absolute_url_from('http://www.google.com/', 'http://www.example.com')
      expect(url).to eq nil
    end

    it 'returns nil if current page url is *not* empty or nil' do
      url = crawl_url.absolute_url_from('/some/path', '')
      expect(url).to be_nil
      url = crawl_url.absolute_url_from('/some/path', nil)
      expect(url).to be_nil
    end

    it 'v2: returns full path for relative url' do
      url = crawl_url.absolute_url_from('/some/path', 'http://example.com')
      expect(url).to eq 'http://example.com/some/path'
    end

    it 'returns full path for full url with same domain as base url' do
      url = crawl_url.absolute_url_from('http://example.com/some/path', '')
      expect(url).to eq 'http://example.com/some/path'
    end
  end

  describe '#eligible_url?' do
    it 'rejects non valid urls' do
      non_eligible = %w(javascript: callto: mailto: tel: skype: facetime: wtai: /email-protection# # .json .zip .rar .pdf .exe .dmg .pkg .dpkg .bat)
      non_eligible.each do |url|
        expect(crawl_url.send(:eligible_url?, url)).to eq false
      end
    end

    it 'accepts valid urls' do
      eligible = %w(www.example.com example.com http://example.com https://example.com /path path ?q=query)
      eligible.each do |url|
        expect(crawl_url.send(:eligible_url?, url)).to eq true
      end
    end
  end
end
