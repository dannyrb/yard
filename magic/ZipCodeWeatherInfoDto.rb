# A plain ruby object for storing location information specific to a zip code.
#
# @author Danny Brown
# @since 1.0.0
# @attr_reader [String] zip_code 5-digit zipcode
# @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attr_reader @attr_*
# @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attribute @!attribute
class ZipCodeWeatherInfo
  # @return [Float]
  attr_reader :temperature
  # @return [Float]
  attr_reader :cloud
  # @return [Float]
  attr_reader :rain
  # @return [Float]
  attr_reader :humidity
  # @return [Float]
  attr_reader :fog
  # @return [Integer]
  attr_reader :symbol
  # @return [WeatherInfoWind]
  attr_reader :wind
  # @return [WeatherInfoSunAndMoon]
  attr_reader :sun_and_moon


  # @param [Hash] opts The options to create a ZipCodeWeatherInfo
  # @option opts [String] :temperature
  # @option opts [String] :cloud
  # @option opts [String] :rain
  # @option opts [String] :humidity
  # @option opts [String] :fog
  # @option opts [String] :symbol
  # @option opts [Hash] :wind
  # @return [ZipCodeWeatherInfo] initializes a new instance of ZipCodeWeatherInfo
  def initialize(opts)
    # Celsius to Farenheit
    @temperature = (opts['temperature'].to_f * (9 / 5)) + 32
    @cloud = opts['cloud'].to_f
    @rain = opts['rain'].to_f
    @humidity = opts['humidity'].to_f
    @fog = opts['fog'].to_f
    @wind = WeatherInfoWind.new(opts['wind'])
    @sun_and_moon = WeatherInfoSunAndMoon.new(opts['sunrise'], opts['sunset'], opts['moonphase'])
  end
end

class WeatherInfoWind
  attr_reader :speed
  attr_reader :direction

  # @param [Hash] opts The options to create a WeatherInfoWind
  # @option opts [Integer] :speed
  # @option opts [String] :direction
  # @returns [WeatherInfoWind]
  def initialize(opts = {})
    @speed = opts['speed']
    @direction = opts['direction']
  end
end

class WeatherInfoSunAndMoon
  # @return [String]
  attr_reader :sunrise
  # @return [String]
  attr_reader :sunset
  # @return [Float]
  attr_reader :moonphase

  # @returns [WeatherInfoSunAndMoon]
  def initialize(sunrise, sunset, moonphase)
    @sunrise = sunrise
    @sunset = sunset
    @moonphase = moonphase
  end
end