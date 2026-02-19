# frozen_string_literal: true

class CustomAttribute::UserSerializer < ActiveModel::Serializer

  attribute :integer, type: :integer do
    123
  end

  attribute :any, typescript: 'any' do
    'any value'
  end

end
