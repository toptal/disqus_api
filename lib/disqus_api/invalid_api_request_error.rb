module DisqusApi
  class InvalidApiRequestError < StandardError
    attr_reader :response

    # @param [Hash] response
    # @param [Stirng] message
    def initialize(response, message = response.inspect)
      @response = response
      super(message)
    end
  end
end

