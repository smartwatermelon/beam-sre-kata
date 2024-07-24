# ./modules/serverless/lambda/index.rb

require 'json'
require 'net/http'
require 'uri'

def load_config
  JSON.parse(File.read('config.json'))
end

def fetch_breweries(config)
  uri = URI(config['api_url'])
  params = {
    by_city: config['city'],
    by_state: config['state'],
    per_page: config['per_page']
  }
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get_response(uri)
  return [] unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
end

def format_brewery_data(breweries)
  breweries.map do |brewery|
    {
      name: brewery['name'],
      street: brewery['street'],
      phone: brewery['phone']
    }
  end.sort_by { |brewery| brewery[:name] }
end

def handler(event:, context:)
  config = load_config
  breweries = fetch_breweries(config)
  formatted_data = format_brewery_data(breweries)

  # Log the formatted data to CloudWatch
  puts JSON.generate(formatted_data)

  { statusCode: 200, body: JSON.generate(formatted_data) }
end