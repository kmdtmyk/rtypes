# frozen_string_literal: true

class Child < ApplicationRecord
  belongs_to :parent
  has_many :grandchildren
end
