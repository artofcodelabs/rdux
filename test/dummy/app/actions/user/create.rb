# frozen_string_literal: true

class User
  class Create
    def self.call(payload)
      user = User.create(payload['user'])
      return Rdux::Result[ok: false, val: { errors: user.errors }] unless user.persisted?

      val = { user_id: user.id }
      Rdux::Result[ok: true, val:, result: val]
    end
  end
end
