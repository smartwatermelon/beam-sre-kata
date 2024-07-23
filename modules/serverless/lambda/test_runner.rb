# modules/serverless/lambda/test_runner.rb

require 'json'
require_relative 'test_lambda'

def handler(event:, context:)
  puts "GEM_PATH: #{ENV['GEM_PATH']}"
  puts "LOAD_PATH: #{$LOAD_PATH}"
  puts "Installed gems: #{Gem.loaded_specs.keys}"

  begin
    test_result = TestLambda.run_tests
    puts JSON.generate(test_result)

    {
      statusCode: test_result[:success] ? 200 : 500,
      body: JSON.generate(test_result)
    }
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace.join("\n")

    {
      statusCode: 500,
      body: JSON.generate({ error: e.message, backtrace: e.backtrace })
    }
  end
end