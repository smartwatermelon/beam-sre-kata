# modules/serverless/lambda/test_lambda.rb

require 'minitest/autorun'
require 'json'
require_relative 'index'

class TestLambda < Minitest::Test
  # Test the format_brewery_data function
  def test_format_brewery_data
    breweries = [
      {'name' => 'Brewery B', 'street' => '123 Main St', 'phone' => '123-456-7890'},
      {'name' => 'Brewery A', 'street' => '456 Oak St', 'phone' => '098-765-4321'}
    ]
    formatted = format_brewery_data(breweries)
    assert_equal 2, formatted.length
    assert_equal 'Brewery A', formatted.first[:name]
    assert_equal '123 Main St', formatted.last[:street]
    assert_equal '098-765-4321', formatted.first[:phone]
  end
end