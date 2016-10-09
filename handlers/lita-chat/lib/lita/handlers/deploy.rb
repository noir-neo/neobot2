module Lita
  module Handlers
    class Chat < Handler
      route /deploy/i, :deploy, command: true

      def deploy(response)
        if robot.auth.user_is_admin?(response.user)
          response.reply `pwd`
        else
          response.reply "Permission denied."
        end
      end

      Lita.register_handler(self)
    end
  end
end
