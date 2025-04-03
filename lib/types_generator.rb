# frozen_string_literal: true

require_relative "types_generator/version"

class TypesGenerator
  class Error < StandardError; end
  # Your code goes here...

  def initialize(name)
    @name = name
  end

  def file_name
    "#{@name}.ts"
  end

end
