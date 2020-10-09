# Ruby
require 'time'
require 'securerandom'

# External
require 'down'
require 'faraday'
require 'faraday_middleware'
require 'fileutils'

# Internal
require_relative 'ZipCodeLocationInfoDto'
require_relative 'ZipCodeWeatherInfoDto'

# Two types of tags:
# 1. Meta-data tags --> @ prefix
#   - Semantic and separate from text blob
#   - More easily parsed by supportive tooling
#   - Supports custom meta-data tags
#   - example: `@param` https://rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List
# 2. Behavioral tags (directives) --> @! prefix
#   - Affect the parsing context and objects themselves
#   - Indicate that the tag may modify or create new objects when called

# @meta_data_tag some data
# @!directive_tag some data
# @see https://rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List Meta-data Tag List
# @see https://rubydoc.info/gems/yard/file/docs/Tags.md#Directive_List Directive Tag List
class ApiStuff
  # @see http://auroraslive.io/#/api/v1/introduction Auroras.live API Documentation
  def initialize
    # @TODO: Accounts for DST, but we're lazy
    # Time.now.in_time_zone('America/New_York').utc_offset
    zone_offset = Time.now.utc_offset
    @aurora_base_api_url = 'https://api.auroras.live/'
    @aurora_api_version = 'v1/'
    @aurora_client = Faraday.new(url: @aurora_base_api_url, params: { 'tz' => zone_offset.to_s }) do |faraday|
      faraday.adapter(Faraday.default_adapter) # net/http
      faraday.response :json
    end

    @zipcode_UNSAFE_MAGIC = 'Cv8ZjhdEhKMmpyNnIP3Ks6BbWFXP2egWrbru2JbdQ0OIhE2PEhxwTH6DiyEoyTwH'
    @zipcode_base_api_url = 'https://www.zipcodeapi.com/'
    @zipcode_api_version = 'rest'
    @zipcode_client = Faraday.new(url: @zipcode_base_api_url) do |faraday|
      faraday.adapter(Faraday.default_adapter)
      faraday.response :json
    end
  end
  
  # @return [string]
  def download_random_image
    image_ids = get_image_ids('cam')
    random_image_id = image_ids.sample
    get_image_by_id(random_image_id)
  end

  #
  #
  # @param [String] zipcode
  # @return [ZipCodeWeatherInfo]
  def get_weather_for_zip(zipcode)
    location_info = get_location_info_from_zipcode(zipcode)
    weather_info = get_weather_info_from_lat_long(location_info.latitude, location_info.longitude)

    weather_info
  end

  private

  #
  #
  # @param [Float] latitude
  # @param [Float] longitude
  # @return [ZipCodeWeatherInfo]
  def get_weather_info_from_lat_long(latitude, longitude)
    response = @aurora_client.get(@aurora_api_version, {
        'lat' => latitude,
        'long' => longitude,
        'type' => 'weather'
    })

    data = response.body
    weather_info = ZipCodeWeatherInfo.new(data)

    weather_info
  end

  # Pings external API to retrieve location information for a given zipcode. Information includes:
  # longitude, latitude, city, and state.
  #
  # @note limited to 10 API requests per hour per API key
  #
  # @example
  #   get_location_info_from_zipcode(43065)
  #   #=> ZipCodeLocationInfoDto
  #   #=> .zip_code   --> '43065'
  #   #=> .longitude  --> 40.177519
  #   #=> .latitude   --> -83.094353
  #   #=> .city       --> 'Powell'
  #   #=> .state      --> 'OH'
  #
  # @param [String] zipcode 5-digit zipcode
  # @return [ZipCodeLocationInfoDto]
  # @see https://www.zipcodeapi.com/API Zip Code to Location Information endpoint
  def get_location_info_from_zipcode(zipcode)
    request_url = "/#{@zipcode_api_version}/#{@zipcode_UNSAFE_MAGIC}/info.json/#{zipcode}/degrees"
    response = @zipcode_client.get(request_url)
    data = response.body

    location_info = ZipCodeLocationInfoDto.new(data['zip_code'], data['lat'], data['lng'], data['city'], data['state'])

    location_info
  end

  # Get an array of valid image ids that can be retrieved from the auroras
  # API. Optionally filter by a category.
  #
  # @example Get all available image ids
  #   get_image_ids()
  #   #=> ['cressy', 'kilpisjarvi', 'kiruna', 'rothney', 'tromso']
  #
  # @example Get image ids filtered by a category of image
  #   get_image_ids('cam')
  #   #=> ['cressy', 'rothney']
  #
  # @param [string] category 'cam' | 'satellite' | 'chart'
  # @return [Array<string>]
  def get_image_ids(category = nil)
    response = @aurora_client.get(@aurora_api_version, {
      'action' => 'list',
      'type' => 'images'
    })

    data = response.body
    images = data['images']

    filtered_images = !category.nil? ? images.values.select { |image| image['category'] == category } : images
    filtered_image_ids = filtered_images.reduce([]) { |arr, image| arr.push(image['id']) }

    filtered_image_ids
  end

  # Takes a valid `image_id`, then downloads and persists that image locally.
  # Valid `image_id`s can be found using the Auroras image list endpoint. Image
  # names will be postfixed with a random hex to avoid naming conflicts.
  #
  # @example Request and persist a specific image
  #   get_image_by_id("cressy")
  #   #=> "/image_downloads/cressy-1ab84be584"
  #
  # @param [string] image_id
  # @return [string] relative filepath for image
  # @see http://auroraslive.io/#/api/v1/images Auroras Live Images API
  def get_image_by_id(image_id)
    request_url = get_request_url_with_params({ 'image' => image_id, 'type' => 'images' })
    tempfile = Down.download(request_url)
    file_path = "/image_downloads/#{image_id}-#{SecureRandom.hex(5)}"
    FileUtils.mv(tempfile.path, ".#{file_path}")

    return file_path
  end

  # Builds a GET query string URL for the Aurora Client given a hash of key/value parameters
  #
  # @example Generate URL using simple key value pairs
  #   get_request_url_with_params({ 'foo' => 'bar' })
  #   #=> "https://api.auroras.live/v1/?foo=bar"
  #
  # @param [hash] params string key/value pairs that correspond to query string parameters
  # @return [string] Request URL
  def get_request_url_with_params(params)
    url = "#{@aurora_base_api_url}#{@aurora_api_version}?"
    params.each { |key, value| url = "#{url}#{key}=#{value}&" }

    url
  end
end