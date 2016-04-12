require "spec_helper"

describe Lita::Handlers::Gmail, lita_handler: true do
  it { is_expected.to route('mail') }
  it { is_expected.to route('mail').to(:mail) }

  it '#mail' do
    send_message('mail')
    expect(replies.last).not_to eq("")
  end
end
