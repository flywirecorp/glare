require 'glare/api_response'

RSpec.describe Glare::ApiResponse do
  let(:error_response) { load_fixture('error_response') }
  let(:empty_response) { load_fixture('empty_result') }

  context 'when api returns success response' do
    it 'returns api reponse' do
      expect do
        Glare::ApiResponse.new(empty_response).valid!
      end.not_to raise_error
    end
  end

  context 'when api returns error response' do
    it 'raises an exception if api result is not success' do
      expect do
        Glare::ApiResponse.new(error_response).valid!
      end.to raise_error(Glare::Errors::ApiError)
    end

    it 'shows error messages' do
      expect do
        Glare::ApiResponse.new(error_response).valid!
      end.to raise_error(Glare::Errors::ApiError).
        with_message('DNS Validation Error')
    end
  end
end
