module DisqusApi
  class Response < ActiveSupport::HashWithIndifferentAccess
    attr_reader :request, :arguments, :content

    # @param [Request] request
    # @param [Hash] arguments
    def initialize(request, arguments = {})
      @request   = request
      @arguments = arguments
      @content   = request.perform(@arguments)

      super(@content)
    end

    # Fetches all records going through pagination
    # @return [Array<Hash>]
    def all
      [].tap do |result|
        next_response = self

        while next_response
          result.concat(next_response.body)
          next_response = next_response.next
        end
      end
    end

    # @return [Response, nil]
    def next
      if has_next?
        request.response(arguments.merge(cursor: next_cursor))
      end
    end

    def has_next?
      self['cursor']['hasNext']
    end

    # @return [String]
    def next_cursor
      self['cursor']['next']
    end

    # @return [Hash]
    def body
      self['response']
    end

    # @return [Integer]
    def code
      self['code']
    end
  end
end