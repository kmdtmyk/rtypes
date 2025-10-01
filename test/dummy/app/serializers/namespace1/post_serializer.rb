# frozen_string_literal: true

class Namespace1::PostSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
  )

  belongs_to :user

end
