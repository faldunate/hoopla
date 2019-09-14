class Value
    include ActiveModel::Model
    attr_accessor :href, :metric, :owner, :value, :updated_at, :metric_id

    def id
        self.href.split('/').last if self.href.present?
    end

    def user
        User.find(self.owner['href'].split('/').last)
    rescue
        {}
    end

    def metric_id
        self.metric['href'].split('/').last
    end

    def save
        if self.id.nil?
            self.owner = { kind: 'user', href: "https://api.hoopla.net/users/#{self.owner}"}.with_indifferent_access
            body = self.as_json
            body.delete("metric")
            Hoopla::Client.hoopla_client.post("/metrics/#{self.metric}/values", body.to_json, 'application/vnd.hoopla.metric-value+json')
        else
            Hoopla::Client.hoopla_client.put("/metrics/#{metric_id}/values/#{id}", self.to_json, 'application/vnd.hoopla.metric-value+json')
        end
    end

    class << self
        def all(metric_id)
            values = Hoopla::Client.hoopla_client.get("/metrics/#{metric_id}/values", {
                'Accept': 'application/vnd.hoopla.metric-value-list+json'
            })
            values.collect{ |value| new(value) }.select{ |value| value if value.owner['kind'] == 'user'}
        end

        def find(id, metric_id)
            value = Hoopla::Client.hoopla_client.get("/metrics/#{metric_id}/values/#{id}", {
                'Accept': 'application/vnd.hoopla.metric-value-list+json'
            })
            new(value)
        end
    end
end