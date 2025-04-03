# frozen_string_literal: true

RSpec.describe TypesGenerator do

  it "has a version number" do
    expect(TypesGenerator::VERSION).not_to be nil
  end

  describe 'file_name' do

    example do
      types_generator = TypesGenerator.new('User')
      expect(types_generator.file_name).to eq 'User.ts'
    end

  end

  describe 'file_content' do

    example do
      types_generator = TypesGenerator.new('User')
      expect(types_generator.file_content).to eq <<~EOS
      type User = {
        id: number | null
        name: string
      }

      export default User
      EOS
    end

  end

end
