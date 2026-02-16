# frozen_string_literal: true

class Nest::BelongsTo::ChildSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  belongs_to :parent

  class ParentSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

    has_many :children

    class ChildSerializer < ActiveModel::Serializer

      attributes(
        :created_at,
      )

    end

  end

end
