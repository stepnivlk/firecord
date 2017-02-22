require './firecord'

class TestRecord
  attr_accessor :test
  include Firecord::Record

  field :name, :string
  field :priority, :integer
end
