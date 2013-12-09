module DisqusApi
  class Namespace
    attr_reader :api, :name, :specification

    # @param [Api] api
    # @param [String, Symbol] name
    def initialize(api, name)
      @api = api
      @name = name
      @specification = @api.specifications[@name]
      @specification or raise(ArgumentError, "No such namespace <#@name>")
    end

    # @param [String, Symbol] action
    # @param [Hash] arguments Action params
    # @return [Request]
    def build_action_request(action, arguments = {})
      Request.new(api, name, action, arguments)
    end

    # @param [String, Symbol, Hash] action
    # @param [Hash] arguments
    # @return [Hash] response
    def request_action(action, arguments = {})
      build_action_request(action, arguments).response
    end
    alias_method :perform_action, :request_action

    # DisqusApi.v3.users.---->>[details]<<-----
    #
    # Forwards all API calls under a specific namespace
    def method_missing(method_name, *args)
      if specification.has_key?(method_name.to_s)
        request_action(method_name, *args)
      else
        raise NoMethodError, "No action #{method_name} registered for #@name namespace"
      end
    end

    def respond_to?(method_name, include_private = false)
      specification[method_name.to_s] || super
    end
  end
end