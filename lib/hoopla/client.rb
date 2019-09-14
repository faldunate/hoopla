module Hoopla
    class Client
        CLIENT_ID = ENV['CLIENT_ID']
        CLIENT_SECRET = ENV['CLIENT_SECRET']
        @@endpoint = 'https://api.hoopla.net'.freeze

        def initialize()
            descriptor
        end

        def self.hoopla_client
            @@hoopla_client_singleton ||= Hoopla::Client.new
        end

        def get(relative_url, options)
            response = client.get(relative_url, headers: options)
            if response.status == 200
                JSON.parse(response.body)
            else
                raise StandardError('Invalid response from ')
            end
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

        def token
            if !@token
                login

                if !@token
                    login
                end
            end
            @token
        end

        def connection
            @conn ||= Faraday.new(url: @@endpoint) do |faraday|
              faraday.response :logger
              faraday.adapter Faraday.default_adapter
              faraday.basic_auth CLIENT_ID, CLIENT_SECRET
            end
          end

        def client
            @client ||= Faraday.new(url: @@endpoint) do |faraday|
                faraday.response :logger
                faraday.adapter Faraday.default_adapter
                faraday.use FaradayMiddleware::EncodeJson
                faraday.authorization :Bearer, token
            end
        end

        def descriptor
            descriptor_url = @@endpoint
            @descriptor ||= self.get(descriptor_url, {'Accept' => 'application/vnd.hoopla.api-descriptor+json'})
        end
    end
end