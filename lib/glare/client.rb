# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'logger'
require 'glare/api_response'
require 'httpx/adapters/faraday'

module Glare
  class Client
    BASE_HOST = 'https://api.cloudflare.com'
    BASE_PATH = '/client/v4'

    def initialize
      @http = Faraday::Connection.new(BASE_HOST) do |builder|
        builder.request  :json
        builder.response :logger, Logger.new(STDERR) if ENV['CF_DEBUG']
        builder.response :json, content_type: /\bjson$/

        builder.adapter :httpx
      end
    end

    def from_global_api_key(email, auth_key)
      @headers = {
        'X-Auth-Email' => email,
        'X-Auth-Key' => auth_key
      }
      self
    end

    def from_scoped_api_token(api_token)
      @headers = {
        'Authorization' => "Bearer #{api_token}"
      }
      self
    end

    def get(query, params)
      ApiResponse.new(@http.get(BASE_HOST + BASE_PATH + query, params, @headers)).valid!
    end

    def post(query, data)
      ApiResponse.new(@http.post(BASE_HOST + BASE_PATH + query, data, @headers)).valid!
    end

    def put(query, data)
      ApiResponse.new(@http.put(BASE_HOST + BASE_PATH + query, data, @headers)).valid!
    end

    def delete(query, params=nil)
      ApiResponse.new(@http.delete(BASE_HOST + BASE_PATH + query, params, @headers)).valid!
    end
  end
end
