class Metric
    include ActiveModel::Model
    attr_accessor :href, :name, :type, :currency, :links, :format_rounded_to, :currency_code, :updated_at

    def id
        self.href.split('/').last
    end

    class << self
        def all
            metrics = Hoopla::Client.hoopla_client.get('/metrics', {
                'Accept': 'application/vnd.hoopla.metric-list+json'
            })
            metrics.collect{ |metric| new(metric) }
        end
    end
end