# ./modules/serverless/lambda/test_lambda.rb

require 'minitest/autorun'
require_relative 'index'

class TestLambda < Minitest::Test
  def test_load_config
    config = load_config
    assert_kind_of Hash, config
    assert_includes config, 'api_url'
    assert_includes config, 'city'
    assert_includes config, 'state'
    assert_includes config, 'per_page'
  end

  def test_format_brewery_data
    breweries = [
      {'name' => 'Brewery B', 'street' => '123 Main St', 'phone' => '123-456-7890'},
      {'name' => 'Brewery A', 'street' => '456 Oak St', 'phone' => '098-765-4321'}
    ]
    formatted = format_brewery_data(breweries)
    assert_equal 2, formatted.length
    assert_equal 'Brewery A', formatted.first[:name]
    assert_equal '123 Main St', formatted.last[:street]
  end

  def test_handler
    result = handler(event: {}, context: nil)
    assert_kind_of Hash, result
    assert_equal 200, result[:statusCode]
    assert_kind_of String, result[:body]
    body = JSON.parse(result[:body])
    assert_kind_of Array, body
  end
end