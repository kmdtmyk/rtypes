# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :name,
    :admin,
  )

  attribute :any, typescript: 'any' do
    'any value'
  end

  has_many :posts
  has_one :latest_post

  # ignore non exists association
  has_many :non_exists
  has_one :non_exist1
  belongs_to :non_exist2

end
