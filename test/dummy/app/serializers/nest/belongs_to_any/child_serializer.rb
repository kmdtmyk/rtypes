# frozen_string_literal: true

class Nest::BelongsToAny::ChildSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  belongs_to :parent

  class ParentSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

    has_many :children

  end

end
