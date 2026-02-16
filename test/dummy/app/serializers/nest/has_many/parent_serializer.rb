# frozen_string_literal: true

class Nest::HasMany::ParentSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  has_many :children

  class ChildSerializer < ActiveModel::Serializer

    attributes(
      :id
    )

    has_many :grandchildren

    class GrandchildSerializer < ActiveModel::Serializer

      attributes(
        :id
      )

    end

  end

end
