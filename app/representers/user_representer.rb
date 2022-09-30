class UserRepresenter
    def initialize(user)
        @user = user
    end

    def as_json
        {
            id: user.id,
            username: user.username,
            created_at: user.created_at,
            number_of_plans: user.plans.count
        }
    end

    private
        attr_reader :user
end