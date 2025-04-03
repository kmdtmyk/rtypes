# frozen_string_literal: true

RSpec.describe TypesGenerator do

  it "has a version number" do
    expect(TypesGenerator::VERSION).not_to be nil
  end

  example 'file_name' do
    types_generator = TypesGenerator.new('User')
    expect(types_generator.file_name).to eq 'User.ts'
  end

end
