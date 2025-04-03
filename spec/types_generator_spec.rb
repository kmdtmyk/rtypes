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

    example 'has_many' do
      types_generator = TypesGenerator.new('User')
      expect(types_generator.file_content).to eq <<~EOS
      import Post from './Post'

      type User = {
        id: number | null
        name: string
        posts?: Array<Post>
      }

      export default User
      EOS
    end

    example 'belongs_to' do
      types_generator = TypesGenerator.new('Post')
      expect(types_generator.file_content).to eq <<~EOS
      import User from './User'

      type Post = {
        id: number | null
        title: string
        body: string
        user?: User
      }

      export default Post
      EOS
    end

  end

end
