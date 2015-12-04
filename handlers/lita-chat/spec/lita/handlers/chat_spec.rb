require "spec_helper"

describe Lita::Handlers::Chat, lita_handler: true do
  it { is_expected.to route('ohayo') }
  it { is_expected.to route('ohayo').to(:ohayo) }
  it { is_expected.to route('おはよ') }
  it { is_expected.to route('おはよ').to(:ohayo) }
  it 'return greeting "ohayo"' do
    send_message('ohayo')
    expect(replies.last).to eq('おはようございます。')
  end
end
