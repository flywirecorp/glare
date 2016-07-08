module Glare
  class ApiResponse
    def initialize(result)
      @result = result
    end

    def first_result_id
      result['result'].first['id']
    end

    def contents
      Array(result['result']).map { |item| item['content'] }
    end

    def result
      @result.content
    end
  end
  private_constant :ApiResponse
end
