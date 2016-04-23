module DisqusApi
  class ApiServerError < StandardError
    attr_reader :response

    # @param [Hash] response
    # @param [String] message
    def initialize(response, message = response.inspect)
      @response = response
      super(message)
    end
  end
end
