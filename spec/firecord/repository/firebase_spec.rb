require 'spec_helper'

describe Firecord::Repository::Firebase do
  context 'Valid credentials and valid set of records given' do
    Firecord.configure do |config|
      config.credentials_file = \
        File.join(
          File.dirname(__dir__), '../', 'fixtures', 'fake_credentials.json'
        )
    end

    let(:firebase) {
      VCR.use_cassette('firebase_init') { described_class.new('todos') }
    }
    let(:credentials) { firebase.instance_variable_get(:@credentials) }
    let(:root) { firebase.instance_variable_get(:@root) }

    it 'Sets own variables' do
      expect(credentials).to_not be_nil
      expect(credentials).to be_a(Firecord::Credentials)
      expect(root).to eq('todos')
    end

    it 'Sets base_uri of it\'s class' do
      expect(firebase.class.base_uri)
        .to eq("https://#{credentials.project_id}.firebaseio.com")
    end

    context 'Accessing public instance methods' do
      let(:all) { VCR.use_cassette('firebase_all_valid') { firebase.all } }
      let(:fields_valid) {
        [
          OpenStruct.new(name: :name),
          OpenStruct.new(name: :priority)
        ]
      }

      describe '#all' do
        it 'lists all the records' do
          expect(all).to be_a(Array)
          expect(all.size).to_not eq(0)
          expect(all[0]).to be_a(Hash)
        end
      end

      describe '#get' do
        let(:id) { all[0][:id] }
        let(:response) {
          VCR.use_cassette('firebase_get_valid') {
            firebase.get(id)
          }
        }

        it 'Gets the record by valid ID' do
          expect(response).to_not be_nil
          expect(response).to be_a(Hash)
          expect(response[:id]).to eq(id)
        end

        it 'Tries to get a record by invalid ID and returns nil' do
          id = 'invalid'
          record = VCR.use_cassette('firebase_get_invalid') { firebase.get(id) }

          expect(record).to be_nil
        end
      end

      describe '#post' do
        let(:record) {
          OpenStruct.new(
            name: 'fake',
            priority: 23,
            fields: fields_valid
          )
        }
        let(:response) {
          VCR.use_cassette('firebase_post_valid_attributes') {
            firebase.post(record)
          }
        }

        it 'Creates new record when record with valid attributes given' do
          expect(response).to_not be_nil
          expect(response).to be_a(Hash)
          expect(response[:name]).to be_a(String)
        end
      end

      describe '#patch' do
        let(:record_valid) {
          OpenStruct.new(
            id: all[1][:id],
            name: 'fake',
            priority: 23,
            fields: fields_valid
          )
        }
        let(:record_invalid_attributes) {
          OpenStruct.new(
            id: all[2][:id],
            invalid_a: 'invalid_a',
            invalid_b: 'invalid_b',
            fields: fields_valid
          )
        }
        let(:record_invalid_id) {
          OpenStruct.new(
            id: 'invalid_id',
            name: 'fake',
            priority: 23,
            fields: fields_valid
          )
        }
        let(:response_valid) {
          VCR.use_cassette('firebase_patch_valid') {
            firebase.patch(record_valid)
          }
        }
        let(:response_invalid_attributes) {
          VCR.use_cassette('firebase_patch_invalid_attributes') {
            firebase.patch(record_invalid_attributes)
          }
        }
        let(:response_invalid_id) {
          VCR.use_cassette('firebase_patch_invalid_id') {
            firebase.patch(record_invalid_attributes)
          }
        }

        it 'Updates existing record when valid record given' do
          expect(response_valid).to_not be_nil
          expect(response_valid).to be_a(Hash)
          expect(response_valid[:name])
            .to eq(record_valid.name)
          expect(response_valid[:priority])
            .to eq(record_valid.priority)
        end

        it 'Does not update record when record with invalid attributes given' do
          expect(response_invalid_attributes).to_not be_nil
          expect(response_invalid_attributes[:invalid_a]).to be_nil
          expect(response_invalid_attributes[:invalid_b]).to be_nil
        end

        it 'Fails when invalid ID given' do
          expect(response_invalid_id).to_not be_nil
          expect(response_invalid_id).to be_a(Hash)
          expect(response_invalid_id[:name]).to be_nil
          expect(response_invalid_id[:priority]).to be_nil
        end
      end

      describe '#delete' do
        let(:response_valid) {
          VCR.use_cassette('firebase_delete_valid') {
            firebase.delete(all[3][:id])
          }
        }

        it 'Deletes record and returns true when valid ID given' do
          expect(response_valid).to be_truthy
        end
      end
    end
  end
end
