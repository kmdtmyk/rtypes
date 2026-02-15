# frozen_string_literal: true

class Nest::UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  has_many :posts

  class PostSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

  end

end
