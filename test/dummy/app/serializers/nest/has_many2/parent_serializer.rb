# frozen_string_literal: true

class Nest::HasMany2::ParentSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  has_many :children

  class ChildSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

    belongs_to :some_category, serializer: Nest::HasMany2::SomeCategorySerializer

  end

end
