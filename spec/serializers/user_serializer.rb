# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
  )

  has_many :posts

end
