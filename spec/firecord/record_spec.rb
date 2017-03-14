require 'spec_helper'

context 'Valid credentials given' do
  Firecord.configure do |config|
    config.credentials_file = \
      File.join(
        File.dirname(__dir__), 'fixtures', 'fake_credentials.json'
      )
  end

  context 'Empty records' do
    class Dummy
      include Firecord::Record

      root_key 'empty_root'

      field :name, :string
      field :timestamps
    end

    context 'Extended to class' do
      describe '.fields' do
        it 'Lists all the fields' do
          expect(Dummy.fields).to eq([
            OpenStruct.new(name: :id, type: :private_key),
            OpenStruct.new(name: :name, type: :string),
            OpenStruct.new(name: :created_at, type: :created_at),
            OpenStruct.new(name: :updated_at, type: :updated_at),
          ])
        end
      end

      describe '.all' do
        let(:all) { VCR.use_cassette('model_all') { Dummy.all } }

        it 'Returns an empty array when there are no records' do
          expect(all).to eq([])
        end
      end

      describe '.find' do
        let(:find) { VCR.use_cassette('model_find') { Dummy.find('id') } }

        it 'Returns nil when there are no records with given ID' do
          expect(find).to eq(nil)
        end
      end
    end
  end
end
