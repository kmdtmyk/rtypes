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
    assert_equal rtypes.file_name, 'User.ts'
  end

  test 'file_path' do
    skip if ENV['CI']
    rtypes = Rtypes.new('User')
    assert_equal rtypes.file_path, '/app/test/dummy/app/javascript/types/User.ts'
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal rtypes.file_path, '/app/test/dummy/app/frontend/entrypoints/types/User.ts'
  end

  test 'file_content has_many' do
    rtypes = Rtypes.new('User')
    assert_equal rtypes.file_content, <<~EOS
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
    rtypes = Rtypes.new('Post')
    assert_equal rtypes.file_content, <<~EOS
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
    assert_equal Rtypes.config.path, 'app/javascript/types'
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal Rtypes.config.path, 'app/frontend/entrypoints/types'
  end

end
