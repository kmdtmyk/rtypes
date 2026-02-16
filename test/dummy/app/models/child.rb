# frozen_string_literal: true

class Child < ApplicationRecord
  has_many :grandchildren
end
