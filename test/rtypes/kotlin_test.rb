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
    rtypes = Rtypes::Kotlin.new(BookSerializer)
    assert_equal <<~EOS, rtypes.file_content
      data class Book(
          val id: Long? = null,
          /**
           * タイトル
           */
          val title: String? = null,
          /**
           * 価格
           */
          val price: Int? = null,
          /**
           * 発売日
           */
          val releaseDate: String? = null,
          /**
           * ファイルサイズ
           */
          val fileSize: String? = null,
          val booleanNotNullOn: Boolean = false,
          val booleanNotNullOff: Boolean? = null
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
