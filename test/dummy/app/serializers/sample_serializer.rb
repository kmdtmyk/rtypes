# frozen_string_literal: true

class SampleSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :string,
    :string_not_null,
    :text,
    :integer,
    :bigint,
    :decimal,
    :date,
    :datetime,
    :boolean,
    :boolean_without_not_null,
  )

end


