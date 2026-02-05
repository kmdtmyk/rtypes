require "test_helper"

class Rtypes::AnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    assert_equal [
      { name: 'id', type: :integer, sql_type: 'bigint', comment: nil },
      { name: 'title', type: :string, sql_type: 'character varying', comment: 'タイトル' },
      { name: 'price', type: :integer, sql_type: 'integer', comment: '価格' },
      { name: 'release_date', type: :date, sql_type: 'date', comment: '発売日' },
      { name: 'file_size', type: :decimal, sql_type: 'numeric', comment: 'ファイルサイズ' },
      { name: 'boolean_not_null_on', type: :boolean, sql_type: 'boolean', null: false, comment: nil },
      { name: 'boolean_not_null_off', type: :boolean, sql_type: 'boolean', null: true, comment: nil },
    ], Rtypes::Analyzer.new(BookSerializer).attributes

    assert_equal [
      { name: 'id', type: :integer, sql_type: 'bigint', comment: nil },
      { name: 'name', type: :string, sql_type: 'character varying', comment: '氏名' },
      { name: 'admin',type: :boolean, sql_type: 'boolean', null: false, comment: '管理者' },
    ], Rtypes::Analyzer.new(UserSerializer).attributes
  end

  test 'attributes any' do
    assert_equal [
      { name: 'any', type: nil, sql_type: nil, comment: nil, options: { typescript: 'any' } },
    ], Rtypes::Analyzer.new(Namespace4::UserSerializer).attributes
  end

  test 'associations' do
    assert_equal [
      { type: :belongs_to, name: 'user', class_name: 'User', serializer: UserSerializer },
      { type: :belongs_to, name: 'delete_user', class_name: 'User', serializer: UserSerializer },
      { type: :has_many, name: 'comments', class_name: 'Comment', serializer: nil },
    ], Rtypes::Analyzer.new(PostSerializer).associations

    assert_equal [
      { type: :has_many, name: 'posts', class_name: 'Post', serializer: PostSerializer },
      { type: :has_one, name: 'latest_post', class_name: 'Post', serializer: PostSerializer },
    ], Rtypes::Analyzer.new(UserSerializer).associations

    assert_equal [], Rtypes::Analyzer.new(Namespace3::UserSerializer).associations
  end

end

