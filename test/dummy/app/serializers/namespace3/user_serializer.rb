# frozen_string_literal: true

class Namespace3::UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
  )

  # ignore non exists association
  has_many :non_exists
  has_one :non_exist1
  belongs_to :non_exist2

end
