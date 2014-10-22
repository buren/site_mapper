# SiteMapper
[![Code Climate](https://codeclimate.com/github/buren/site_mapper.png)](https://codeclimate.com/github/buren/site_mapper) [![Dependency Status](https://gemnasium.com/buren/site_mapper.svg)](https://gemnasium.com/buren/site_mapper)
 [![Gem Version](https://badge.fury.io/rb/site_mapper.svg)](http://badge.fury.io/rb/site_mapper)

Find all URLs on given domain.

## Installation
Install the gem:
```bash
gem install site_mapper
```

## Usage

Command line usage:
```bash
site_mapper example.com # Crawl all found links on page that has with example.com domain
```

Ruby usage:
```ruby
require 'site_mapper'
SiteMapper.archive('example.com') # Crawl all found links on page that has with example.com domain
```

View archive: [https://web.archive.org/web/*/http://example.com](https://web.archive.org/web/*/http://example.com)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
