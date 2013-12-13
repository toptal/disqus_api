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

    # Fetches all response collection entries going through pagination
    # @return [Array<Hash>]
    def all
      each_resource.to_a
    end

    # Iterates through each response entry through all pages
    # @return [Enumerator<Hash>]
    def each_resource(&block)
      Enumerator.new do |result|
        each_page { |resources| resources.each { |resource| result << resource } }
      end.each(&block)
    end

    # Iterates through every single page
    # @return [Enumerator<Array<Hash>>]
    def each_page(&block)
      Enumerator.new do |result|
        next_response = self

        while next_response
          result << next_response.body.to_a
          next_response = next_response.next
        end
      end.each(&block)
    end

    # @return [Response]
    def next!
      self.merge!(self.next) if has_next?
      self
    end

    # @return [Response]
    def prev!
      self.merge!(self.prev) if has_prev?
      self
    end

    # @return [Response, nil]
    def next
      if has_next?
        request.response(arguments.merge(cursor: next_cursor))
      end
    end

    # @return [Response, nil]
    def prev
      if has_prev?
        request.response(arguments.merge(cursor: prev_cursor))
      end
    end

    def has_next?
      self['cursor']['hasNext']
    end

    def has_prev?
      self['cursor']['hasPrev']
    end

    # @return [String]
    def next_cursor
      self['cursor']['next']
    end

    # @return [String]
    def prev_cursor
      self['cursor']['prev']
    end

    # @return [Hash]
    def body
      self['response']
    end
    alias_method :response, :body

    # @return [Integer]
    def code
      self['code']
    end
  end
end