# frozen_string_literal: true

class User
  class Create
    def call(payload)
      user = User.new(payload['user'])
      Rdux::Result[ok: user.save, val: { user_id: user.id }]
    end
  end
end
