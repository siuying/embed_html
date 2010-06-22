# Rakefile
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('embed_html', '0.2.3') do |p|
  p.description    = "Download and embed images in html using base64 data encoding"
  p.summary        = "Download or process a HTML page, find images there, download them and embed it into the HTML using Base64 data encoding"
  p.url            = "http://github.com/siuying/embed_html"
  p.author         = "Francis Chong"
  p.email          = "francis@ignition.hk"
  p.ignore_pattern = ["tmp/*", "script/*", "*.html"]
  p.runtime_dependencies = ["hpricot"]
end

