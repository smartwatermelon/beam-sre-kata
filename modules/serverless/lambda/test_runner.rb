# modules/serverless/lambda/test_runner.rb

puts "Starting test_runner.rb"
puts "Ruby version: #{RUBY_VERSION}"
puts "Current directory: #{Dir.pwd}"
puts "Contents of current directory: #{Dir.entries('.')}"
puts "Contents of /var/task: #{Dir.entries('/var/task')}"
puts "Contents of /var/task/vendor/bundle: #{Dir.entries('/var/task/vendor/bundle')}"
puts "ENV variables: #{ENV.to_h}"

require 'bundler/setup'
require_relative 'test_lambda'

def handler(event:, context:)
  puts "Handler started"
  puts "BUNDLE_GEMFILE: #{ENV['BUNDLE_GEMFILE']}"
  puts "GEM_PATH: #{ENV['GEM_PATH']}"
  puts "LOAD_PATH: #{$LOAD_PATH}"
  puts "Bundler.bundle_path: #{Bundler.bundle_path}"
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