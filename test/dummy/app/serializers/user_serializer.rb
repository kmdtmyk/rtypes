# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
    :admin,
  )

  has_many :posts

end
