require "test_helper"

class RtypesTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test "it has a version number" do
    assert Rtypes::VERSION
  end

  test 'file_name' do
    rtypes = Rtypes.new('User')
    assert_equal 'User.ts', rtypes.file_name
    rtypes = Rtypes.new('user')
    assert_equal 'User.ts', rtypes.file_name
    rtypes = Rtypes.new(UserSerializer)
    assert_equal 'User.ts', rtypes.file_name
    rtypes = Rtypes.new(Namespace1::PostSerializer)
    assert_equal 'namespace1/Post.ts', rtypes.file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    rtypes = Rtypes.new('User')
    assert_equal '/app/test/dummy/app/javascript/types/User.ts', rtypes.file_path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal '/app/test/dummy/app/frontend/entrypoints/types/User.ts', rtypes.file_path
  end

  test 'file_content has_many and has_one' do
    rtypes = Rtypes.new('User')
    assert_equal <<~EOS, rtypes.file_content
      import Post from './Post'

      type User = {
        id: number
        name: string
        admin: boolean
        any: any
        posts?: Array<Post>
        latestPost?: Post
      }

      export default User
    EOS
  end

  test 'file_content belongs_to' do
    rtypes = Rtypes.new('Post')
    assert_equal <<~EOS, rtypes.file_content
      import User from './User'

      type Post = {
        id: number
        title: string
        body: string
        user?: User
        deleteUser?: User
        comments?: Array<any>
      }

      export default Post
    EOS
  end

  test 'file_content with namespace' do
    rtypes = Rtypes.new(Namespace1::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import User from '../User'

      type Post = {
        id: number
        title: string
        user?: User
      }

      export default Post
    EOS
  end

  test 'file_content with namespace2' do
    rtypes = Rtypes.new(Namespace2::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import User from './User'

      type Post = {
        id: number
        title: string
        user?: User
      }

      export default Post
    EOS
  end

  test 'config' do
    assert_equal 'app/javascript/types', Rtypes.config.path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal 'app/frontend/entrypoints/types', Rtypes.config.path
  end

  test 'config_file_content' do
    assert_equal <<~EOS.strip, Rtypes.config_file_content
      Rtypes.config.path = 'app/javascript/types'
      Rtypes.config.types = {
        integer: 'number',
        decimal: 'string',
        boolean: 'boolean',
      }
    EOS
  end

  test 'invalid model name' do
    error = assert_raises RuntimeError do
      Rtypes.new('Foo')
    end
    assert_equal %(Error: Invalid model name "Foo"), error.message
  end

end
