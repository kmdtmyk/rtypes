# frozen_string_literal: true

class Api::PostSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
    :body,
  )

end
