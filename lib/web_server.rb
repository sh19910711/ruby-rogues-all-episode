require "sinatra/base"
require "rss"
require "rest_client"
require "nokogiri"
require "yaml"

def filename
  "all_episode.yaml"
end

def episode_info(url)
  body = RestClient.get(url)
  doc = Nokogiri::HTML.parse(body)
  episode = {
    :mp3 => doc.xpath('//a[@download]').attribute('href').value
  }
  episode
end

def load_cache
  FileUtils.touch filename unless File.exists?(filename)
  YAML.load(File.read(filename)) || {}
end

def save_cache(data)
  File.write filename, data.to_yaml
end

def all_episode
  cache = load_cache
  url   = "http://rubyrogues.com/episode-guide/"
  body  = RestClient.get(url)
  doc   = Nokogiri::HTML.parse(body)
  links = doc.xpath('//div[@class="format_text"]/p/a')

  links.map do |link|
    url = link.attribute('href').value
    next cache[url] if cache.has_key?(url)

    puts "fetch: #{link.inner_text} / #{link.attribute('href').value}"
    cache[url] = {
      :title => link.inner_text,
      :url => episode_info(url)[:mp3]
    }
    save_cache cache
    sleep 1
    cache[url]
  end
end

class WebServer < Sinatra::Base
  get "/feed" do
    # generate rss
    rss = RSS::Maker.make("2.0") do |maker|

      maker.channel.about = "hello"
      maker.channel.title = "hello"
      maker.channel.description = "hello"
      maker.channel.link = "http://url/to"

      all_episode.each do |episode|
        item = maker.items.new_item
        item.link = "http://url/to/item"
        item.title = episode[:title]
        item.enclosure.type = "audio/mpeg"
        item.enclosure.length = 0
        item.enclosure.url = episode[:url]
      end
    end

    # render
    content_type "application/xml"
    rss.to_s
  end
end

