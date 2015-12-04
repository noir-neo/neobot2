module Lita
  module Handlers
    class Chat < Handler
      route(/ohayo|おはよ/i, :ohayo)

      def ohayo(response)
        response.reply("おはようございます。")
      end

      Lita.register_handler(self)
    end
  end
end
