# A plain ruby object for storing location information specific to a zip code.
#
# @author Danny Brown
# @since 1.0.0
# @attr_reader [String] zip_code 5-digit zipcode
# @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attr_reader @attr_*
# @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attribute @!attribute
class ZipCodeLocationInfoDto
  # @return [String] 5-digit zipcode
  attr_reader :zip_code
  # @return [Float]
  attr_reader :latitude
  # @return [Float]
  attr_reader :longitude
  # @return [String]
  attr_reader :city
  # @return [String]
  attr_reader :state

  # @param [String] zip_code 5-digit zipcode
  # @param [Float] latitude
  # @param [Float] longitude
  # @param [String] city
  # @param [String] state
  # @return [ZipCodeLocationInfoDto] initializes a new instance of ZipCodeLocationInfoDto
  def initialize(zip_code, latitude, longitude, city, state)
    @zip_code = zip_code
    @latitude = latitude
    @longitude = longitude
    @city = city
    @state = state
  end
end
