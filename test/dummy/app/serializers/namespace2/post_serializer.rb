# frozen_string_literal: true

class Namespace2::PostSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
  )

  belongs_to :user

end
