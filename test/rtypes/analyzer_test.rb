require "test_helper"

class Rtypes::AnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    attributes = Rtypes::Analyzer.new(SampleSerializer).attributes
    assert_equal({ name: 'id', type: :integer, sql_type: 'bigint', comment: nil }, attributes[0])
    assert_equal({ name: 'string', type: :string, sql_type: 'character varying', comment: nil }, attributes[1])
    assert_equal({ name: 'text', type: :text, sql_type: 'text', comment: nil }, attributes[2])
    assert_equal({ name: 'integer', type: :integer, sql_type: 'integer', comment: nil }, attributes[3])
    assert_equal({ name: 'decimal', type: :decimal, sql_type: 'numeric', comment: nil }, attributes[4])
    assert_equal({ name: 'date', type: :date, sql_type: 'date', comment: nil }, attributes[5])
    assert_equal({ name: 'datetime', type: :datetime, sql_type: 'timestamp without time zone', comment: nil }, attributes[6])
    assert_equal({ name: 'boolean', type: :boolean, sql_type: 'boolean', null: false, comment: nil }, attributes[7])
    assert_equal({ name: 'boolean_not_null_off', type: :boolean, sql_type: 'boolean', null: true, comment: nil }, attributes[8])

    attributes = Rtypes::Analyzer.new(UserSerializer).attributes
    assert_equal({ name: 'id', type: :integer, sql_type: 'bigint', comment: nil }, attributes[0])
    assert_equal({ name: 'name', type: :string, sql_type: 'character varying', comment: '氏名' }, attributes[1])
    assert_equal({ name: 'admin',type: :boolean, sql_type: 'boolean', null: false, comment: '管理者' }, attributes[2])
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
