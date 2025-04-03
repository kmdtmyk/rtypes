require "test_helper"

class TypesGeneratorTest < ActiveSupport::TestCase

  def setup
    TypesGenerator.instance_variable_set(:@config, nil)
  end

  test "it has a version number" do
    assert TypesGenerator::VERSION
  end

  test 'file_name' do
    types_generator = TypesGenerator.new('User')
    assert_equal types_generator.file_name, 'User.ts'
  end

  test 'file_path' do
    skip if ENV['CI']
    types_generator = TypesGenerator.new('User')
    assert_equal types_generator.file_path, '/app/test/dummy/app/javascript/types/User.ts'
    TypesGenerator.config.path = 'app/frontend/entrypoints/types'
    assert_equal types_generator.file_path, '/app/test/dummy/app/frontend/entrypoints/types/User.ts'
  end

  test 'file_content has_many' do
    types_generator = TypesGenerator.new('User')
    assert_equal types_generator.file_content, <<~EOS
    import Post from './Post'

    type User = {
      id: number | null
      name: string
      posts?: Array<Post>
    }

    export default User
    EOS
  end

  test 'file_content belongs_to' do
    types_generator = TypesGenerator.new('Post')
    assert_equal types_generator.file_content, <<~EOS
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

  test 'config' do
    assert_equal TypesGenerator.config.path, 'app/javascript/types'
    TypesGenerator.config.path = 'app/frontend/entrypoints/types'
    assert_equal TypesGenerator.config.path, 'app/frontend/entrypoints/types'
  end

end
