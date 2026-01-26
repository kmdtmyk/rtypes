require "test_helper"

class RtypesTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test "it has a version number" do
    assert Rtypes::VERSION
  end

  test 'file_name' do
    rtypes = Rtypes.new(UserSerializer)
    assert_equal 'User.ts', rtypes.file_name
    rtypes = Rtypes.new(Namespace1::PostSerializer)
    assert_equal 'namespace1/Post.ts', rtypes.file_name
    rtypes = Rtypes.new(nil)
    assert_nil rtypes.file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    rtypes = Rtypes.new(UserSerializer)
    assert_equal '/app/test/dummy/app/javascript/types/User.ts', rtypes.file_path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal '/app/test/dummy/app/frontend/entrypoints/types/User.ts', rtypes.file_path
    rtypes = Rtypes.new(nil)
    assert_nil rtypes.file_path
  end

  test 'file_content has_many and has_one' do
    rtypes = Rtypes.new(UserSerializer)
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
    rtypes = Rtypes.new(PostSerializer)
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
      import User1 from './User'
      import User2 from '../User'

      type Post = {
        id: number
        title: string
        user?: User1
        deleteUser?: User2
      }

      export default Post
    EOS
  end

  test 'file_content nil' do
    rtypes = Rtypes.new(nil)
    assert_nil rtypes.file_content
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

  test 'name_to_serializer' do
    assert_equal UserSerializer, Rtypes.name_to_serializer('user')
    assert_equal UserSerializer, Rtypes.name_to_serializer('User')
    assert_nil Rtypes.name_to_serializer('foo')
    assert_nil Rtypes.name_to_serializer(nil)
  end

  test 'path_to_serializer' do
    assert_equal UserSerializer, Rtypes.path_to_serializer('/app/test/dummy/app/serializers/user_serializer.rb')
    assert_equal Namespace2::UserSerializer, Rtypes.path_to_serializer('/app/test/dummy/app/serializers/namespace2/user_serializer.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/user_serializer copy.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/dummy_serializer.rb')
    assert_nil Rtypes.path_to_serializer(nil)
  end

end
