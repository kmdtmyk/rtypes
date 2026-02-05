# frozen_string_literal: true

class HasMany::UserSerializer < ActiveModel::Serializer

  has_many :posts

end
