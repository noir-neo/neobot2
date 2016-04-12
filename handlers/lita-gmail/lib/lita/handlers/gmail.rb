require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Lita
  module Handlers
    class Gmail < Handler
      route(/mail/i, :mail)

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

      def find_mail_by_id(id)
        response = @service.get_user_message('me', id)

        body = response.payload.parts ?
          response.payload.parts.first.body.data :
          response.payload.body.data
        headers = response.payload.headers

        {
          subject: headers.select { |e| e.name == 'Subject'}.first.value,
          # from: headers.select { |e| e[:name] == 'From'}.first.value,
          date: Time.parse(headers.select { |e| e.name == 'Date'}.first.value),
          body: body.force_encoding('utf-8'),
        }
      end

      def find_mail(query)
        ids = @service.list_user_messages('me', q: query)

        results = []
        ids.messages.each do |message|
          results.push(find_mail_by_id(message.id))
        end
        results
      end

      def mail(response)
        @service = Google::Apis::GmailV1::GmailService.new
        @service.client_options.application_name = APPLICATION_NAME
        @service.authorization = authorize(response)

        mails = find_mail('newer_than:1d')

        texts = <<-EOS
1日以内に届いたメールはこちらになります。
        EOS

        mails.each do |m|
          texts << <<-EOS
---
#{m[:date]}
#{m[:subject]}
#{m[:body]}
          EOS
        end

        texts << <<-EOS
---
以上です。
        EOS

        response.reply(texts)
      end

      Lita.register_handler(self)
    end
  end
end
