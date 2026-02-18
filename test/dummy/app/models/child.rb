# frozen_string_literal: true

class Child < ApplicationRecord
  belongs_to :parent
  belongs_to :some_category
  has_many :grandchildren
end
