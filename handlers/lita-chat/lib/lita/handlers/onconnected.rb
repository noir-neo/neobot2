module Lita
  module Handlers
    class Onconnected < Handler
      on :connected, :launch_notifier

      def launch_notifier(payload)
        Lita.config.robot.admins.each do |id|
          admin = User.find_by_id(id)
          source = Lita::Source.new(user: admin)

          robot.send_message(source, 'I confirmed boot sequence. Connection successful. N.E.O. is in readiness.')
        end
      end

      Lita.register_handler(self)
    end
  end
end
