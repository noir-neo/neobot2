require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Lita
  module Handlers
    class Gmail < Handler
      route(/get mail/i, :mail)

      OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
      APPLICATION_NAME = 'Gmail API Ruby Quickstart'
      CLIENT_SECRETS_PATH = 'client_secret.json'
      CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                                   "gmail-ruby-quickstart.yaml")
      SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

      def authorize(response)
        FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

        client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
        authorizer = Google::Auth::UserAuthorizer.new(
          client_id, SCOPE, token_store)
        user_id = 'default'
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
          url = authorizer.get_authorization_url(
            base_url: OOB_URI)
          response.reply "Open the following URL in the browser and enter the " +
               "resulting code after authorization"
          response.reply url
          code = gets
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI)
        end
        credentials
      end

      def mail(response)
        # Initialize the API
        service = Google::Apis::GmailV1::GmailService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = authorize(response)

        # Show the user's labels
        user_id = 'me'
        result = service.list_user_labels(user_id)

        response.reply "Labels:"
        response.reply "No labels found" if result.labels.empty?
        result.labels.each { |label| response.reply "- #{label.name}" }
      end

      Lita.register_handler(self)
    end
  end
end
