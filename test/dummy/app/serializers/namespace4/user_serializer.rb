# frozen_string_literal: true

class Namespace4::UserSerializer < ActiveModel::Serializer

  attribute :any, typescript: 'any' do
    'any value'
  end

end
