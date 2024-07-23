# modules/serverless/lambda/test_lambda.rb
require 'bundler/setup'
require 'minitest'
require_relative 'index'

class TestLambda < Minitest::Test

  def test_fetch_breweries
    config = { 'api_url' => 'https://api.openbrewerydb.org/v1/breweries', 'city' => 'Columbus', 'state' => 'Ohio', 'per_page' => 50 }
    breweries = fetch_breweries(config)
    assert_instance_of Array, breweries
    refute_empty breweries
    assert breweries.all? { |b| b['city'] == 'Columbus' && b['state'] == 'Ohio' }
  end

  def test_format_brewery_data
    breweries = [
      { 'name' => 'Test Brewery', 'street' => '123 Test St', 'phone' => '1234567890' },
      { 'name' => 'Another Brewery', 'street' => '456 Another St', 'phone' => '0987654321' }
    ]
    formatted = format_brewery_data(breweries)
    assert_equal 2, formatted.length
    assert_equal ['Another Brewery', 'Test Brewery'], formatted.map { |b| b[:name] }
    assert formatted.all? { |b| [:name, :street, :phone].all? { |k| b.key?(k) } }
  end

  def self.run_tests
    test_methods = public_instance_methods(false).grep(/^test_/)
    result = { success: true, failures: [] }

    test_methods.each do |method|
      begin
        test_instance = new(method)
        test_instance.send(method)
      rescue Minitest::Assertion => e
        result[:success] = false
        result[:failures] << { test: method, message: e.message }
      end
    end

    result
  end
end