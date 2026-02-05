# frozen_string_literal: true

class SampleSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :string,
    :text,
    :integer,
    :decimal,
    :date,
    :datetime,
    :boolean,
    :boolean_not_null_off,
  )

end


