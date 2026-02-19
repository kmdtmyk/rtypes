require "test_helper"

class Rtypes::TypeScriptTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test 'file_name' do
    assert_equal 'User.ts', Rtypes::TypeScript.new(UserSerializer).file_name
    assert_equal 'namespace1/Post.ts', Rtypes::TypeScript.new(Namespace1::PostSerializer).file_name
    assert_nil Rtypes::TypeScript.new(nil).file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    assert_equal '/app/test/dummy/app/javascript/types/User.ts', Rtypes::TypeScript.new(UserSerializer).file_path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal '/app/test/dummy/app/frontend/entrypoints/types/User.ts', Rtypes::TypeScript.new(UserSerializer).file_path
    assert_nil Rtypes::TypeScript.new(nil).file_path
  end

  test 'file_content' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(SampleSerializer).file_content
      type Sample = {
        id: number
        string: string
        stringNotNull: string
        text: string
        integer: number
        bigint: number
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
    assert_equal <<~EOS, Rtypes::TypeScript.new(CommentAttribute::PostSerializer).file_content
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
    assert_equal <<~EOS, Rtypes::TypeScript.new(HasMany::UserSerializer).file_content
      import Post from '../Post'

      type User = {
        posts?: Array<Post>
      }

      export default User
    EOS
  end

  test 'file_content has_many (any)' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(HasMany::PostSerializer).file_content
      type Post = {
        comments?: Array<any>
      }

      export default Post
    EOS
  end

  test 'file_content has_one' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(HasOne::UserSerializer).file_content
      import Post from '../Post'

      type User = {
        latestPost?: Post
      }

      export default User
    EOS
  end

  test 'file_content belongs_to' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(BelongsTo::PostSerializer).file_content
      import User from '../User'

      type Post = {
        user?: User
        deleteUser?: User
      }

      export default Post
    EOS
  end

  test 'file_content nest has_many' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Nest::HasMany::ParentSerializer).file_content
      type Parent = {
        id: number
        children?: Array<Child>
      }

      type Child = {
        id: number
        grandchildren?: Array<Grandchild>
      }

      type Grandchild = {
        id: number
      }

      export default Parent

      export {
        Child,
        Grandchild,
      }
    EOS
  end

  test 'file_content nest has_many2' do
    skip 'TODO'
    assert_equal <<~EOS, Rtypes::TypeScript.new(Nest::HasMany2::ParentSerializer).file_content
      import SomeCategory from './SomeCategory'

      type Parent = {
        id: number
        children?: Array<Child>
      }

      type Child = {
        id: number
        someCategory?: SomeCategory
      }

      export default Parent

      export {
        Child,
      }
    EOS
  end

  test 'file_content nest belongs_to' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Nest::BelongsTo::ChildSerializer).file_content
      type Child = {
        id: number
        parent?: Parent
      }

      type Parent = {
        id: number
        children?: Array<ChildParentChild>
      }

      type ChildParentChild = {
        createdAt: string
      }

      export default Child

      export {
        Parent,
        ChildParentChild,
      }
    EOS
  end

  test 'file_content nest belongs_to any' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Nest::BelongsToAny::ChildSerializer).file_content
      type Child = {
        id: number
        parent?: Parent
      }

      type Parent = {
        id: number
        children?: Array<any>
      }

      export default Child

      export {
        Parent,
      }
    EOS
  end

  test 'file_content nest belongs_to self' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Nest::BelongsToSelf::ChildSerializer).file_content
      type Child = {
        id: number
        parent?: Parent
      }

      type Parent = {
        id: number
        children?: Array<Child>
      }

      export default Child

      export {
        Parent,
      }
    EOS
  end

  test 'file_content with namespace' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Namespace1::PostSerializer).file_content
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
    assert_equal <<~EOS, Rtypes::TypeScript.new(Namespace2::PostSerializer).file_content
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
    assert_equal <<~EOS, Rtypes::TypeScript.new(CustomAttribute::UserSerializer).file_content
      type User = {
        integer: number
        any: any
      }

      export default User
    EOS
  end

  test 'file_content line space' do
    Rtypes.config.line_space = 1
    assert_equal <<~EOS, Rtypes::TypeScript.new(TwoAttributes::SampleSerializer).file_content
      type Sample = {

        string: string

        integer: number

      }

      export default Sample
    EOS

    Rtypes.config.line_space = -9999
    assert_equal <<~EOS, Rtypes::TypeScript.new(TwoAttributes::SampleSerializer).file_content
      type Sample = {
        string: string
        integer: number
      }

      export default Sample
    EOS
  end

  test 'file_content empty' do
    assert_equal <<~EOS, Rtypes::TypeScript.new(Empty::BookSerializer).file_content
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

  test 'attribute_to_property' do
    assert_equal 'id: number', Rtypes::TypeScript.attribute_to_property(name: 'id', type: :bigint)
    assert_equal 'string: string', Rtypes::TypeScript.attribute_to_property(name: 'string', type: :string)
    assert_equal 'text: string', Rtypes::TypeScript.attribute_to_property(name: 'text', type: :text)
    assert_equal 'integer: number', Rtypes::TypeScript.attribute_to_property(name: 'integer', type: :integer)
    assert_equal 'bigint: number', Rtypes::TypeScript.attribute_to_property(name: 'bigint', type: :bigint)
    assert_equal 'decimal: string', Rtypes::TypeScript.attribute_to_property(name: 'decimal', type: :decimal)
    assert_equal 'date: string', Rtypes::TypeScript.attribute_to_property(name: 'date', type: :date)
    assert_equal 'datetime: string', Rtypes::TypeScript.attribute_to_property(name: 'datetime', type: :datetime)
    assert_equal 'boolean: boolean', Rtypes::TypeScript.attribute_to_property(name: 'boolean', type: :boolean)
    assert_equal 'foo: any', Rtypes::TypeScript.attribute_to_property(name: 'foo', options: { typescript: 'any' })

    assert_equal <<~EOS.strip, Rtypes::TypeScript.attribute_to_property(name: 'text', type: :text, comment: 'こめんと')
    /**
     * こめんと
     */
    text: string
    EOS

    assert_equal <<~EOS.strip, Rtypes::TypeScript.attribute_to_property(name: 'text', type: :text, comment: "1行目\n2行目")
    /**
     * 1行目
     * 2行目
     */
    text: string
    EOS
  end

end
