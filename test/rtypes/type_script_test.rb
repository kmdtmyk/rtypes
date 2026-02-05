require "test_helper"

class Rtypes::TypeScriptTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test 'file_name' do
    rtypes = Rtypes::TypeScript.new(UserSerializer)
    assert_equal 'User.ts', rtypes.file_name
    rtypes = Rtypes::TypeScript.new(Namespace1::PostSerializer)
    assert_equal 'namespace1/Post.ts', rtypes.file_name
    rtypes = Rtypes::TypeScript.new(nil)
    assert_nil rtypes.file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    rtypes = Rtypes::TypeScript.new(UserSerializer)
    assert_equal '/app/test/dummy/app/javascript/types/User.ts', rtypes.file_path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal '/app/test/dummy/app/frontend/entrypoints/types/User.ts', rtypes.file_path
    rtypes = Rtypes::TypeScript.new(nil)
    assert_nil rtypes.file_path
  end

  test 'file_content' do
    rtypes = Rtypes::TypeScript.new(SampleSerializer)
    assert_equal <<~EOS, rtypes.file_content
      type Sample = {
        id: number
        string: string
        text: string
        integer: number
        decimal: string
        date: string
        datetime: string
        boolean: boolean
        booleanWithoutNotNull: boolean
      }

      export default Sample
    EOS
  end

  test 'file_content with comment' do
    rtypes = Rtypes::TypeScript.new(CommentAttribute::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      type Post = {
        /**
         * タイトル
         */
        title: string
      }

      export default Post
    EOS
  end

  test 'file_content has_many' do
    rtypes = Rtypes::TypeScript.new(HasMany::UserSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import Post from '../Post'

      type User = {
        posts?: Array<Post>
      }

      export default User
    EOS
  end

  test 'file_content has_many (any)' do
    rtypes = Rtypes::TypeScript.new(HasMany::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      type Post = {
        comments?: Array<any>
      }

      export default Post
    EOS
  end

  test 'file_content has_one' do
    rtypes = Rtypes::TypeScript.new(HasOne::UserSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import Post from '../Post'

      type User = {
        latestPost?: Post
      }

      export default User
    EOS
  end

  test 'file_content belongs_to' do
    rtypes = Rtypes::TypeScript.new(BelongsTo::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import User from '../User'

      type Post = {
        user?: User
        deleteUser?: User
      }

      export default Post
    EOS
  end

  test 'file_content with namespace' do
    rtypes = Rtypes::TypeScript.new(Namespace1::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import User from '../User'

      type Post = {
        id: number
        /**
         * タイトル
         */
        title: string
        user?: User
      }

      export default Post
    EOS
  end

  test 'file_content with namespace2' do
    rtypes = Rtypes::TypeScript.new(Namespace2::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
      import User1 from './User'
      import User2 from '../User'

      type Post = {
        id: number
        /**
         * タイトル
         */
        title: string
        user?: User1
        deleteUser?: User2
      }

      export default Post
    EOS
  end

  test 'file_content custom attribute' do
    rtypes = Rtypes::TypeScript.new(CustomAttribute::UserSerializer)
    assert_equal <<~EOS, rtypes.file_content
      type User = {
        any: any
      }

      export default User
    EOS
  end

  test 'file_content empty' do
    rtypes = Rtypes::TypeScript.new(Empty::BookSerializer)
    assert_equal <<~EOS, rtypes.file_content
      type Book = {

      }

      export default Book
    EOS
  end

  test 'file_content non exist model' do
    rtypes = Rtypes::TypeScript.new(NonExistModelSerializer)
    assert_nil rtypes.file_content
    assert_nil rtypes.generate
  end

  test 'file_content nil' do
    rtypes = Rtypes::TypeScript.new(nil)
    assert_nil rtypes.file_content
    assert_nil rtypes.generate
  end

end
