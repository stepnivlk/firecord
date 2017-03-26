require 'spec_helper'

context 'Valid credentials given' do
  Firecord.configure do |config|
    config.credentials_file = \
      File.join(
        File.dirname(__dir__), 'fixtures', 'fake_credentials.json'
      )
  end

  context 'Fields in class are present, but database is empty' do
    class Dummy
      include Firecord::Record

      root_key 'empty_root'

      field :name, :string
      field :timestamps
    end

    context 'Methods extended to the class' do
      describe '.fields' do
        it 'Lists all the fields' do
          expect(Dummy.fields).to eq([
            OpenStruct.new(name: :id, type: :private_key),
            OpenStruct.new(name: :name, type: :string),
            OpenStruct.new(name: :created_at, type: :datetime),
            OpenStruct.new(name: :updated_at, type: :datetime),
          ])
        end
      end

      describe '.all' do
        let(:all) { VCR.use_cassette('invalid_model_all') { Dummy.all } }

        it 'Returns an empty array when there are no records' do
          expect(all).to eq([])
        end
      end

      describe '.find' do
        let(:find) { VCR.use_cassette('invalid_model_find') { Dummy.find('id') } }

        it 'Returns nil when there are no records with given ID' do
          expect(find).to eq(nil)
        end
      end

      describe '.where' do
        context 'valid accessors given' do
          let(:where) {
            VCR.use_cassette('invalid_model_where_valid') {
              Dummy.where(name: 'name')
            }
          }

          it 'Returns nil when there are no records with given ID' do
            expect(where).to eq([])
          end
        end

        context 'invalid accessors given' do
          it 'Throws an exception' do
            expect {
              Dummy.where(name_invalid: 'name')
            }.to raise_error(Firecord::InvalidQuery)
          end
        end
      end
    end

    context 'Fields in class are present and there are records in database' do
      class DummyValid
        include Firecord::Record

        root_key 'root'

        field :name, :string
        field :age, :integer
        field :skill, :float
        field :timestamps
      end

      before(:all) do
        3.times do |index|
          VCR.use_cassette("valid_model_bootstrap_#{index}") {
            DummyValid
              .new(name: "name_#{index}", age: index, skill: index)
              .save
          }
        end
      end

      after(:all) do
        DummyValid.all.each_with_index do |record, index|
          VCR.use_cassette("valid_model_cleanup_#{index}") {
            record.delete
          }
        end
      end

      let(:all) { VCR.use_cassette('valid_model_all') { DummyValid.all } }
      let(:first) { all[0] }

      context 'Methods extended to the class' do
        describe '.all' do
          it 'Returns an array of all records' do
            expect(all).to_not eq([])
            expect(all.size).to eq(3)
          end
        end

        describe '.find' do
          let(:find) {
            VCR.use_cassette('valid_model_find') { DummyValid.find(all[0].id) }
          }

          it 'Returns record with given ID' do
            expect(find).to_not be_nil
            expect(find).to be_a(DummyValid)
            expect(find.name).to eq('name_0')
          end
        end

        describe '.where' do
          context 'valid accessors given' do
            let(:where) {
              VCR.use_cassette('valid_model_where') {
                DummyValid.where(age: 2)
              }
            }

            it 'Returns an array of records fulfilling given condition' do
              expect(where.size).to eq(1)
              expect(where[0].name).to eq(all[2].name)
            end
          end
        end
      end

      context 'Methods included to a class' do
        it 'responds to the \'ID\'' do
          expect(first.id).to_not be_nil
        end

        it 'responds to the \'name\'' do
          expect(first.name).to eq('name_0')
        end

        it 'responds to the \'age\'' do
          expect(first.age).to eq(0)
        end

        it 'responds to the \'skill\'' do
          expect(first.skill).to eq(0.0)
        end

        it 'responds to the \'created_at\'' do
          expect(first.created_at).to be_a(DateTime)
        end

        it 'responds to the \'updated_at\'' do
          expect(first.updated_at).to be_nil
        end

        it 'serializes itself for inspect' do
          output = "#<DummyValid" \
                   " id=#{first.id}" \
                   " name=\"name_0\"" \
                   " age=0" \
                   " skill=0.0" \
                   " created_at=2017-03-26T22:10:53+01:00" \
                   " updated_at=nil>"

          expect(first.inspect).to eq(output)
        end

        it 'throws an error while accessing invalid field' do
          expect { first.name_invalid }.to raise_error(NoMethodError)
        end

        it 'Retypes integer when assigning string field' do
          first.name = 23
          expect(first.name).to eq('23')
        end

        it 'Retypes string when assigning integer field' do
          first.age = '23'
          expect(first.age).to eq(23)
        end

        it 'Retypes string when assigning float field' do
          first.skill = '23.23'
          expect(first.skill).to eq(23.23)
        end

        it 'Assigns nil when invalid type given' do
          first.age =  {a: 1}
          expect(first.age).to eq(nil)
        end
      end
    end
  end
end
