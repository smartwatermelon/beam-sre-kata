# ./modules/serverless/lambda/test_lambda.rb

require 'bundler/setup'
require 'minitest'
require 'json'
require_relative 'index'

class TestLambda < Minitest::Test
  def setup
    # Mock the File.read method to return a sample config
    File.stub :read, '{"api_url":"https://test.api","city":"TestCity","state":"TestState","per_page":10}' do
      @config = load_config
    end
  end

  def test_load_config
    assert_equal 'https://test.api', @config['api_url']
    assert_equal 'TestCity', @config['city']
    assert_equal 'TestState', @config['state']
    assert_equal 10, @config['per_page']
  end

  def test_fetch_breweries
    # Mock Net::HTTP to return a sample response
    mock_response = '{"name":"Test Brewery","city":"TestCity","state":"TestState"}'
    Net::HTTP.stub :get_response, OpenStruct.new(body: mock_response, code: '200') do
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
    
    # Mock the necessary methods
    File.stub :read, '{"api_url":"https://test.api","city":"TestCity","state":"TestState","per_page":10}' do
      Net::HTTP.stub :get_response, OpenStruct.new(body: '[{"name":"Test Brewery","city":"TestCity","state":"TestState","street":"Test St","phone":"1234567890"}]', code: '200') do
        result = handler(event: event, context: context)
        assert_equal 200, result[:statusCode]
        body = JSON.parse(result[:body])
        assert_instance_of Array, body
        assert_equal 1, body.length
        assert_equal 'Test Brewery', body[0]['name']
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
      end
    end

    result
  end
end