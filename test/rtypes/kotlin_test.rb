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
    rtypes = Rtypes::Kotlin.new(SampleSerializer)
    assert_equal <<~EOS, rtypes.file_content
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
    rtypes = Rtypes::Kotlin.new(CommentAttribute::PostSerializer)
    assert_equal <<~EOS, rtypes.file_content
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

end
