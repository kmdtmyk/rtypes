# frozen_string_literal: true

class BookSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
    :price,
    :release_date,
    :file_size,
  )

end
