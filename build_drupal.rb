#!/usr/bin/ruby
require 'yaml'
require 'rexml/document'
include REXML
require 'open-uri'
settings = YAML::load(open(ARGV[0]))
version = settings["base_setting"]["version"]
update_base_url = settings["base_setting"]["update_url"]

def fetch_download_url update_base_url,projectname,version
  f = open("#{update_base_url}/#{projectname}/#{version}")
  doc = REXML::Document.new(f)
  # p doc.elements['project'].elements["releases"]
  url = XPath.first(doc,"/project/releases/release/download_link").text
  f.close
  return url
end

#fetch drupal
url = fetch_download_url( update_base_url,"drupal",version)
#parser to drupal filename

filename = url[(url.rindex("/")+1)..-1]
durpal_dirname = filename[0...filename.index(".tar.gz")]
p "downloading drupal-#{version}"
`wget #{url} && tar vzxf #{filename} && rm #{filename}`
p "Down. Start downloading modules"
for mod in settings["modules"]
  p "downloading #{mod['name']}"
  url = fetch_download_url update_base_url,mod["name"],version
  filename = url[(url.rindex("/")+1)..-1]
  dirname = filename[0...filename.rindex("-#{version}")]
  `wget #{url} && tar vzxf #{filename} && rm #{filename} && mv  #{dirname} #{durpal_dirname}/modules`
  p "done"
end
