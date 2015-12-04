module Lita
  module Handlers
    class Chat < Handler
      route(/ohayo|おはよ/i, :ohayo)

      def ohayo(response)
        if robot.auth.user_is_admin?(response.user)
          response.reply("おはよう、パパ。")
        else
          response.reply("おはようございます。")
        end
      end

      Lita.register_handler(self)
    end
  end
end
