# frozen_string_literal: true

require 'thor'
require 'json'
require './magic/ApiStuff.rb'

# https://www.rubyguides.com/2018/12/ruby-argv/
class RailsCLI < Thor
  class_option :verbose, type: :boolean, aliases: ''

  desc 'download_random_image', 'Create a new rails app'

  def download_random_image
    documented_api = ApiStuff.new
    r_image = documented_api.download_random_image

    pretty_print_json_to_console(r_image)
  end

  desc 'get_weather_for_zip ZIPCODE', 'Generate controller / model / migration'

  def get_weather_for_zip(zipcode)
    documented_api = ApiStuff.new
    weather_info = documented_api.get_weather_for_zip(zipcode)

    puts "The weather for Zip Code: #{zipcode}"
    puts "Location:"
    puts "It is #{weather_info.temperature} degrees out"
    puts "Cloud: #{weather_info.cloud}; Rain: #{weather_info.rain}; Humidity: #{weather_info.humidity}; Fog: #{weather_info.fog}"
    puts ""
    puts "The sunrises at #{weather_info.sun_and_moon.sunrise} and sets at #{weather_info.sun_and_moon.sunset}"
    puts "The current moon phase is: #{weather_info.sun_and_moon.moonphase}"
  end
end

def pretty_print_json_to_console(json)
  puts JSON.pretty_generate(json)
end

RailsCLI.start(ARGV)
