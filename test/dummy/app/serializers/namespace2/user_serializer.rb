# frozen_string_literal: true

class Namespace2::UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
  )

end
