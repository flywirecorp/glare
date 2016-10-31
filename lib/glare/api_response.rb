require 'glare/errors'

module Glare
  class ApiResponse
    def initialize(response)
      @response = response
    end

    def result
      content['result']
    end

    def valid!
      raise Glare::Errors::ApiError.new(errors) unless success?
      self
    end

    private

    def success?
      content['success']
    end

    def content
      @response.content
    end

    def errors
      content['errors'].map { |e| e['message'] }.join(',')
    end
  end
end
