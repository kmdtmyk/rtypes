# frozen_string_literal: true

class OneAttribute::PostSerializer < ActiveModel::Serializer

  attributes(
    :title,
  )

end
