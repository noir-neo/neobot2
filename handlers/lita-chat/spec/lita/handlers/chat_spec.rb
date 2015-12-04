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

  context "when admin sends message" do
    let(:user1) { Lita::User.create(3) }
    before do
      allow(robot.auth).to receive(:user_is_admin?).with(user1).and_return(true)
    end

    it 'return greeting "ohayo, papa"' do
      send_message('ohayo', as: user1)
      expect(replies.last).to eq('おはよう、パパ。')
    end
  end
end
