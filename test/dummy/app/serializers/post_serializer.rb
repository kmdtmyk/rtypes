# frozen_string_literal: true

class PostSerializer < ActiveModel::Serializer

  attributes(
    :id,
    :title,
    :body,
  )

  belongs_to :user
  belongs_to :delete_user

  has_many :comments

end
