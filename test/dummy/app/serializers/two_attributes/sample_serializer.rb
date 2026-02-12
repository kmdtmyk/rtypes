# frozen_string_literal: true

class TwoAttributes::SampleSerializer < ActiveModel::Serializer

  attributes(
    :string,
    :integer,
  )

end
