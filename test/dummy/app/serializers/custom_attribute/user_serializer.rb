# frozen_string_literal: true

class CustomAttribute::UserSerializer < ActiveModel::Serializer

  attribute :any, typescript: 'any' do
    'any value'
  end

end
