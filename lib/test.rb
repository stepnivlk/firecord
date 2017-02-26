require './firecord'

class Test
  include Firecord::Record

  root_key 'todos'

  field :name, :string
  field :priority, :integer
  field :timestamps
end
