# frozen_string_literal: true

class Api::UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
    :admin,
  )

  has_many :posts, serializer: Api::PostSerializer

end
