# frozen_string_literal: true

class HasOne::UserSerializer < ActiveModel::Serializer

  has_one :latest_post

end
