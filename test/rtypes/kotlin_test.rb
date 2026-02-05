require "test_helper"

class Rtypes::KotlinTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test 'file_name' do
    rtypes = Rtypes::Kotlin.new(UserSerializer)
    assert_equal 'User.kt', rtypes.file_name
    rtypes = Rtypes::Kotlin.new(Namespace1::PostSerializer)
    assert_equal 'namespace1/Post.kt', rtypes.file_name
    rtypes = Rtypes::Kotlin.new(nil)
    assert_nil rtypes.file_name
  end

  test 'file_path' do
    skip if ENV['CI']
    rtypes = Rtypes::Kotlin.new(UserSerializer)
    assert_equal '/app/test/dummy/kotlin/User.kt', rtypes.file_path
    rtypes = Rtypes::Kotlin.new(nil)
    assert_nil rtypes.file_path
  end

  test 'file_content' do
    rtypes = Rtypes::Kotlin.new(SampleSerializer)
    assert_equal <<~EOS, rtypes.file_content
      data class Sample(
          val id: Long? = null,
          val string: String? = null,
          val text: String? = null,
          val integer: Int? = null,
          val decimal: String? = null,
          val date: String? = null,
          val datetime: String? = null,
          val boolean: Boolean = false,
          val booleanNotNullOff: Boolean? = null
      )
    EOS
  end

  test 'file_content with comment' do
    rtypes = Rtypes::Kotlin.new(OneAttribute::PostSerializer)
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
