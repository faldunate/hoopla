class User
    include ActiveModel::Model
    attr_accessor :href, :first_name, :last_name, :email, :confirmed_email, :birthday, :anniversary, :updated_at

    def id
        self.href.split('/').last
    end

    def full_name
        "#{self.first_name} #{self.last_name}"
    end

    class << self
        def find(user_id)
            user = Hoopla::Client.hoopla_client.get("/users/#{user_id}", {
                'Accept': 'application/vnd.hoopla.user+json'
            })
            new(user)
        end
    end
end