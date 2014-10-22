# SiteMapper
[![Code Climate](https://codeclimate.com/github/buren/site_mapper.png)](https://codeclimate.com/github/buren/site_mapper) [![Dependency Status](https://gemnasium.com/buren/site_mapper.svg)](https://gemnasium.com/buren/site_mapper)
 [![Gem Version](https://badge.fury.io/rb/site_mapper.svg)](http://badge.fury.io/rb/site_mapper)

Map all links on a given site.  
SiteMapper will try to respect `/robots.txt`

Works great with [Wayback Archiver](https://github.com/buren/wayback_archiver) a gem that crawls your site and submits each URL to the [Internet Archive (Wayback Machine)](https://archive.org/web/).

## Installation
Install the gem:

```bash
gem install site_mapper
```

## Usage

Command line usage:

```bash
# Crawl all found links on page
# that has example.com domain
site_mapper example.com
```

Ruby usage:

```ruby
# Crawl all found links on page
# that has example.com domain
require 'site_mapper'
SiteMapper.map('example.com') do |new_url|
  puts "New URL found: #{new_url}"
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Notes

* Special thanks to the [robots](https://rubygems.org/gems/robots) gem, which provided the bulk of the code in `lib/robots.rb`
