# frozen_string_literal: true

class HasMany::PostSerializer < ActiveModel::Serializer

  has_many :comments

end
