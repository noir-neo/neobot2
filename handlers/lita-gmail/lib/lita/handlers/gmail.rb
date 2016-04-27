require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Lita
  module Handlers
    class Gmail < Handler
      config :query, type: String
      config :template_header, type: String
      config :template_footer, type: String

      route(/kintai/i, :kintai)
      route(/^code\s+(.+)/, :code)

      OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
      APPLICATION_NAME = 'Gmail API Ruby Quickstart'
      CLIENT_SECRETS_PATH = 'client_secret.json'
      CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                                   "gmail-ruby-quickstart.yaml")
      SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

      def authorize
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
          credentials = "Open the following URL in the browser and enter the " +
               "resulting code after authorization\n#{url}"
        end
        credentials
      end

      def find_mail_by_id(id)
        results = service.get_user_message('me', id)

        body = results.payload.parts ?
          results.payload.parts.first.body.data :
          results.payload.body.data
        headers = results.payload.headers

        {
          subject: headers.select { |e| e.name == 'Subject'}.first.value,
          # TODO: アドレスだけ抜いて名前は返したい
          # from: headers.select { |e| e[:name] == 'From'}.first.value,
          date: Time.parse(headers.select { |e| e.name == 'Date'}.first.value),
          body: body.force_encoding('utf-8'),
        }
      end

      def find_mail(query)
        ids = service.list_user_messages('me', q: query)

        return [] unless ids.messages
        ids.messages.map do |message|
          find_mail_by_id(message.id)
        end
      end

      def service
        if @service.nil?
          @service = Google::Apis::GmailV1::GmailService.new
          @service.client_options.application_name = APPLICATION_NAME
          # FIXME: url が返ってきたときの
          @service.authorization = authorize
        end
        @service
      end

      def code(response)
        code = response.matches[0][0]
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end

      def kintai(response)
        mails = find_mail(config.query)

        texts = config.template_header
        # FIXME: query の 'newer:#{Date.today.strftime("%Y/%m/%d")}' 意図したレスポンスにならないので、ここで今日のだけにする?
        mails.each do |m|
          texts << <<-EOS
---
#{m[:date]}
#{m[:subject]}
#{m[:body]}
          EOS
        end
        texts << config.template_footer

        response.reply(texts)
      end

      Lita.register_handler(self)
    end
  end
end
