require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/object/try'
require 'yaml'
require 'json'
require 'faraday'
require 'faraday_middleware'

require 'disqus_api/api'
require 'disqus_api/namespace'
require 'disqus_api/request'
require 'disqus_api/response'
require 'disqus_api/invalid_api_request_error'

module DisqusApi
  VERSION = '0.0.3'

  def self.adapter
    @adapter || Faraday.default_adapter
  end

  def self.adapter=(value)
    @adapter = value
  end

  # @return [ActiveSupport::HashWithIndifferentAccess]
  def self.config
    @config || {}
  end

  # @param [Hash] config
  # @option config [String] :api_secret
  # @option config [String] :api_key
  # @option config [String] :access_token
  def self.config=(config)
    @config = ActiveSupport::HashWithIndifferentAccess.new(config)
  end

  # @param [String] version
  # @return [Api]
  def self.init(version)
    Api.new(version, YAML.load_file(File.join(File.dirname(__FILE__), "apis/#{version}.yml")))
  end

  def self.stub_requests(&block)
    stubbed_requests = Faraday::Adapter::Test::Stubs.new(&block)
    DisqusApi.adapter = [:test, stubbed_requests]
  end

  # @return [Api]
  def self.v3
    @v3 ||= init('3.0')
  end
end
