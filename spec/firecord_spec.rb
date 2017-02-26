require 'spec_helper'

RSpec.describe Firecord do
  it 'has a version number' do
    expect(Firecord::VERSION).not_to be nil
  end

  context 'Configuring credentials path' do
    let(:fake_path) { '/test/credentials.json' }

    before do
      described_class.configure do |config|
        config.credentials_file = fake_path
      end
    end

    it 'Sets credentials_file variable' do
      expect(described_class.credentials_file).to eq(fake_path)
    end
  end
end
