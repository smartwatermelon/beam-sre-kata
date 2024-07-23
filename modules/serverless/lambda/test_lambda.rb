# ./modules/serverless/lambda/test_lambda.rb

require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/mock'
require 'json'
require 'ostruct'
require_relative 'index'

class TestLambda < Minitest::Test
  def setup
    @config = {
      'api_url' => 'https://test.api',
      'city' => 'TestCity',
      'state' => 'TestState',
      'per_page' => 10
    }
  end

  def test_load_config
    File.stub :read, JSON.generate(@config) do
      config = load_config
      assert_equal 'https://test.api', config['api_url']
      assert_equal 'TestCity', config['city']
      assert_equal 'TestState', config['state']
      assert_equal 10, config['per_page']
    end
  end

  def test_fetch_breweries
    mock_response = OpenStruct.new(
      body: JSON.generate([{ 'name' => 'Test Brewery', 'city' => 'TestCity', 'state' => 'TestState' }]),
      code: '200'
    )
    
    Net::HTTP.stub :get_response, mock_response do
      breweries = fetch_breweries(@config)
      assert_instance_of Array, breweries
      refute_empty breweries
      assert breweries.all? { |b| b['city'] == 'TestCity' && b['state'] == 'TestState' }
    end
  end

  def test_format_brewery_data
    breweries = [
      { 'name' => 'Test Brewery', 'street' => '123 Test St', 'phone' => '1234567890' },
      { 'name' => 'Another Brewery', 'street' => '456 Another St', 'phone' => '0987654321' },
      { 'name' => 'Zeta Brewery', 'street' => '789 Zeta St', 'phone' => '5555555555' }
    ]
    formatted = format_brewery_data(breweries)
    assert_equal 3, formatted.length
    assert_equal ['Another Brewery', 'Test Brewery', 'Zeta Brewery'], formatted.map { |b| b[:name] }
    assert formatted.all? { |b| [:name, :street, :phone].all? { |k| b.key?(k) } }
  end

  def test_handler
    event = {}
    context = nil
    
    mock_response = OpenStruct.new(
      body: JSON.generate([{ 'name' => 'Test Brewery', 'city' => 'TestCity', 'state' => 'TestState', 'street' => 'Test St', 'phone' => '1234567890' }]),
      code: '200'
    )
    
    File.stub :read, JSON.generate(@config) do
      Net::HTTP.stub :get_response, mock_response do
        result = handler(event: event, context: context)
        assert_equal 200, result[:statusCode]
        body = JSON.parse(result[:body])
        assert_instance_of Array, body
        assert_equal 1, body.length
        assert_equal 'Test Brewery', body[0][:name]
      end
    end
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
      rescue StandardError => e
        result[:success] = false
        result[:failures] << { test: method, message: "Error: #{e.class} - #{e.message}" }
      end
    end

    if result[:success]
      puts "All tests passed successfully!"
    else
      puts "Test failures:"
      result[:failures].each do |failure|
        puts "  #{failure[:test]}: #{failure[:message]}"
      end
    end

    result
  end
end