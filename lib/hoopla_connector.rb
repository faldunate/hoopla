require 'faraday'
require 'faraday_middleware'

class  HooplaConnector
  CLIENT_ID = ENV['CLIENT_ID']
  CLIENT_SECRET = ENV['CLIENT_SECRET']
  PUBLIC_API_ENDPOINT = 'https://api.hoopla.net'

  def initialize

  end

  def token
    if !@token
      login

      if !@token
        login
      end

    end
    @token
  end

  def put(relative_url, body, content_type)
    client.headers['Content-Type'] = content_type

    response = client.put(relative_url, body)

    if response.status == 200
      JSON.parse(response.body)
    else
      raise StandardError('Invalid response from ')
    end
  end

  def post(relative_url, body, content_type)
    client.headers['Content-Type'] = content_type

    response = client.post(relative_url, body)

    if response.status == 200
      JSON.parse(response.body)
    else
      raise StandardError('Invalid response from ')
    end
  end

  private

  def connection
    @conn ||= Faraday.new(url: PUBLIC_API_ENDPOINT) do |faraday|
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth CLIENT_ID, CLIENT_SECRET
    end
  end

  def login
    response = connection.post('oauth2/token') do |req|
      if @refresh_token
        req.params['grant_type'] = 'refresh_token'
        req.params['refresh_token'] = @refresh_token
      else
        req.params['grant_type'] = 'client_credential'
      end
    end

    if response.status == 200
      json_resp = JSON.parse(response.body)
      @token = json_resp['access_token']
      @refresh_token = json_resp['refresh_token']
    else
      if (@token.nil? && @refresh_token.nil?)    # Nothing to retry
        raise ActiveResource::UnauthorizedAccess
      else
        @token = nil
        @refresh_token = nil
      end
    end
    @token
  end

  def client
    @client ||= Faraday.new(url: PUBLIC_API_ENDPOINT) do |faraday|
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.use FaradayMiddleware::EncodeJson
      faraday.authorization :Bearer, token
    end
  end
end