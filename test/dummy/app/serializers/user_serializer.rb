# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
    :admin,
  )

  attribute :any, typescript: 'any' do
    'any value'
  end

  has_many :posts
  has_one :latest_post

end
