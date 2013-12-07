require 'active_support/hash_with_indifferent_access'
require 'yaml'
require 'json'
require 'faraday'
require 'faraday_middleware'

require 'ruby_disqus/api'
require 'ruby_disqus/request'

module RubyDisqus

  # @return [Hash]
  def self.config
    @config || raise("No configuration specified for Disqus")
  end

  # @param [Hash] config
  def self.config=(config)
    @config = ActiveSupport::HashWithIndifferentAccess.new(config)
  end

  # @return [Api]
  def self.v3
    @v3 ||= Api.new('3.0', YAML.load_file(File.join(File.dirname(__FILE__), 'apis/v3.yml')))
  end
end
