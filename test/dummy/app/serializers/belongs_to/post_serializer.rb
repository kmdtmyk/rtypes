# frozen_string_literal: true

class BelongsTo::PostSerializer < ActiveModel::Serializer

  belongs_to :user
  belongs_to :delete_user

end
