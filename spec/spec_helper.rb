require 'disqus_api'

def load_disqus_config(fname)
  DisqusApi.config = YAML.load_file(File.join(File.dirname(__FILE__), "config/#{fname}"))
end

if ENV['USE_DISQUS_ACCOUNT']
  load_disqus_config("disqus.yml")
else
  load_disqus_config("disqus.yml.example")

  shared_context "perform requests", perform_requests: true do
    before do
      @all_requests_local = true
    end

    let(:request_path) { '' }
    let(:response_body) { nil }
    let(:response_code) { 0 }
    let(:request_type) { :get }

    let(:stubbed_requests) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.public_send(request_type, request_path) { [200, {}, {code: response_code, body: response_body}.to_json] }
      end
    end

    before :each do
      Faraday.default_adapter = [:test, stubbed_requests]
      DisqusApi.v3.reset!
    end
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.formatter = :documentation

  if ENV['USE_DISQUS_ACCOUNT']
    config.filter_run_excluding local: true
  end
end
