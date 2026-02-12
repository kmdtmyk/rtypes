require "test_helper"

class Rtypes::KotlinTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
    Rtypes.config.kotlin_package_name = nil
  end

  test 'file_name' do
    assert_equal 'User.kt', Rtypes::Kotlin.new(UserSerializer).file_name
    assert_equal 'namespace1/Post.kt', Rtypes::Kotlin.new(Namespace1::PostSerializer).file_name
    assert_nil Rtypes::Kotlin.new(nil).file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    assert_equal '/app/test/dummy/kotlin/User.kt', Rtypes::Kotlin.new(UserSerializer).file_path
    assert_equal '/app/test/dummy/kotlin/api/User.kt', Rtypes::Kotlin.new(Api::UserSerializer).file_path
    assert_nil Rtypes::Kotlin.new(nil).file_path
  end

  test 'file_content' do
    assert_equal <<~EOS, Rtypes::Kotlin.new(SampleSerializer).file_content
      data class Sample(
          val id: Long? = null,
          val string: String? = null,
          val text: String? = null,
          val integer: Int? = null,
          val bigint: Long? = null,
          val decimal: String? = null,
          val date: String? = null,
          val datetime: String? = null,
          val boolean: Boolean = false,
          val booleanWithoutNotNull: Boolean? = null
      )
    EOS
  end

  test 'file_content with comment' do
    assert_equal <<~EOS, Rtypes::Kotlin.new(CommentAttribute::PostSerializer).file_content
      data class Post(
          /**
           * タイトル
           */
          val title: String? = null
      )
    EOS
  end

  test 'file_content has_many' do
    assert_equal <<~EOS, Rtypes::Kotlin.new(HasMany::UserSerializer).file_content
      data class User(
          val posts: List<Post>? = null
      )
    EOS

    assert_equal '', Rtypes::Kotlin.new(HasMany::PostSerializer).file_content
  end

  test 'file_content has_one' do
    assert_equal <<~EOS, Rtypes::Kotlin.new(HasOne::UserSerializer).file_content
      data class User(
          val latestPost: Post? = null
      )
    EOS
  end

  test 'file_content belongs_to' do
    assert_equal <<~EOS, Rtypes::Kotlin.new(BelongsTo::PostSerializer).file_content
      data class Post(
          val user: User? = null,
          val deleteUser: User? = null
      )
    EOS
  end

  test 'file_content with package name' do
    Rtypes.config.kotlin_package_name = 'your.package.name'
    assert_equal <<~EOS, Rtypes::Kotlin.new(HasMany::UserSerializer).file_content
      package your.package.name

      data class User(
          val posts: List<Post>? = null
      )
    EOS
  end

  test 'file_content line space' do
    Rtypes.config.line_space = 1
    assert_equal <<~EOS, Rtypes::Kotlin.new(OneAttribute::UserSerializer).file_content
      data class User(

          val id: Long? = null

      )
    EOS

    Rtypes.config.line_space = -9999
    assert_equal <<~EOS, Rtypes::Kotlin.new(OneAttribute::UserSerializer).file_content
      data class User(
          val id: Long? = null
      )
    EOS
  end


  test 'file_content non exist model' do
    rtypes = Rtypes::Kotlin.new(NonExistModelSerializer)
    assert_nil rtypes.file_content
    assert_nil rtypes.generate
  end

  test 'file_content nil' do
    rtypes = Rtypes::Kotlin.new(nil)
    assert_nil rtypes.file_content
    assert_nil rtypes.generate
  end

  test 'attribute_to_property' do
    assert_equal 'val id: Long? = null', Rtypes::Kotlin.attribute_to_property(name: 'id', type: :bigint)
    assert_equal 'val string: String? = null', Rtypes::Kotlin.attribute_to_property(name: 'string', type: :string)
    assert_equal 'val text: String? = null', Rtypes::Kotlin.attribute_to_property(name: 'text', type: :text)
    assert_equal 'val integer: Int? = null', Rtypes::Kotlin.attribute_to_property(name: 'integer', type: :integer)
    assert_equal 'val bigint: Long? = null', Rtypes::Kotlin.attribute_to_property(name: 'bigint', type: :bigint)
    assert_equal 'val decimal: String? = null', Rtypes::Kotlin.attribute_to_property(name: 'decimal', type: :decimal)
    assert_equal 'val date: String? = null', Rtypes::Kotlin.attribute_to_property(name: 'date', type: :date)
    assert_equal 'val datetime: String? = null', Rtypes::Kotlin.attribute_to_property(name: 'datetime', type: :datetime)
    assert_equal 'val boolean: Boolean = false', Rtypes::Kotlin.attribute_to_property(name: 'boolean', type: :boolean, null: false)
    assert_equal 'val boolean: Boolean? = null', Rtypes::Kotlin.attribute_to_property(name: 'boolean', type: :boolean, null: true)

    assert_equal <<~EOS.strip, Rtypes::Kotlin.attribute_to_property(name: 'text', type: :text, comment: 'こめんと')
    /**
     * こめんと
     */
    val text: String? = null
    EOS

    Rtypes.config.kotlin_types = [
      {
        type: :decimal, class: 'BigDecimal', annotation: '@Serializable(with = BigDecimalSerializer::class)',
      }
    ]
    assert_equal <<~EOS.strip, Rtypes::Kotlin.attribute_to_property(name: 'decimal', type: :decimal)
    @Serializable(with = BigDecimalSerializer::class)
    val decimal: BigDecimal? = null
    EOS

  end

end
