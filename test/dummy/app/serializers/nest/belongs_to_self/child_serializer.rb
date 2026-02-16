# frozen_string_literal: true

class Nest::BelongsToSelf::ChildSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  belongs_to :parent

  class ParentSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

    has_many :children, serializer: Nest::BelongsToSelf::ChildSerializer

  end

end
