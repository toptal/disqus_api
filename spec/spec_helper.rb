require 'disqus_api'

DisqusApi.config = YAML.load_file(File.join(File.dirname(__FILE__), "config/disqus.yml"))

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.formatter = :documentation
  config.filter_run_excluding integration: true
end
