# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :delete_user, class_name: 'User', optional: true
end
