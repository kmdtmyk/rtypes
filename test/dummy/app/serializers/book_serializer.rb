# frozen_string_literal: true

class BookSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
    :price,
    :release_date,
    :file_size,
    :boolean_not_null_on,
    :boolean_not_null_off,
  )

end
