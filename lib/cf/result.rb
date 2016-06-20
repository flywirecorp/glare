module Cf
  class Result
    def initialize(result)
      @result = result
    end

    def ocurrences
      result['result_info']['count'].to_i
    end

    def first_result_id
      result['result'].first['id']
    end

    def contents
      Array(result['result']).map { |item| item['content'] }
    end

    private

    def result
      @result.content
    end
  end
  private_constant :Result
end
