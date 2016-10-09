require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/chat"

Lita::Handlers::Chat.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)

require "lita/handlers/deploy"

Lita::Handlers::Deploy.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)

require "lita/handlers/onconnected"

Lita::Handlers::Onconnected.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
