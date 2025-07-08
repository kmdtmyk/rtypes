# frozen_string_literal: true

class User < ApplicationRecord
  has_many :posts
  has_one :latest_post, ->{ order(datetime: :desc) }, class_name: 'Post'
end
