require "test_helper"

class Rtypes::AnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    attributes = Rtypes::Analyzer.new(SampleSerializer).attributes
    assert_equal({ name: 'id', type: :bigint, comment: nil }, attributes[0])
    assert_equal({ name: 'string', type: :string, null: true, comment: nil }, attributes[1])
    assert_equal({ name: 'string_not_null', type: :string, null: false, comment: nil }, attributes[2])
    assert_equal({ name: 'text', type: :text, comment: nil }, attributes[3])
    assert_equal({ name: 'integer', type: :integer, comment: nil }, attributes[4])
    assert_equal({ name: 'bigint', type: :bigint, comment: nil }, attributes[5])
    assert_equal({ name: 'decimal', type: :decimal, comment: nil }, attributes[6])
    assert_equal({ name: 'date', type: :date, comment: nil }, attributes[7])
    assert_equal({ name: 'datetime', type: :datetime, comment: nil }, attributes[8])
    assert_equal({ name: 'boolean', type: :boolean, null: false, comment: nil }, attributes[9])
    assert_equal({ name: 'boolean_without_not_null', type: :boolean, null: true, comment: nil }, attributes[10])

    attributes = Rtypes::Analyzer.new(UserSerializer).attributes
    assert_equal({ name: 'id', type: :bigint, comment: nil }, attributes[0])
    assert_equal({ name: 'name', type: :string, null: true, comment: '氏名' }, attributes[1])
    assert_equal({ name: 'admin',type: :boolean, null: false, comment: '管理者' }, attributes[2])

    assert_equal [
      { name: 'any', type: nil, comment: nil, options: { typescript: 'any' } },
    ], Rtypes::Analyzer.new(CustomAttribute::UserSerializer).attributes

    assert_nil Rtypes::Analyzer.new(NonExistModelSerializer).attributes
  end

  test 'associations' do
    assert_equal [
      { type: :belongs_to, name: 'user', class_name: 'User', serializer: UserSerializer },
      { type: :belongs_to, name: 'delete_user', class_name: 'User', serializer: UserSerializer },
    ], Rtypes::Analyzer.new(BelongsTo::PostSerializer).associations

    assert_equal [
      { type: :has_many, name: 'comments', class_name: 'Comment', serializer: nil },
    ], Rtypes::Analyzer.new(HasMany::PostSerializer).associations

    assert_equal [
      { type: :has_many, name: 'posts', class_name: 'Post', serializer: PostSerializer },
    ], Rtypes::Analyzer.new(HasMany::UserSerializer).associations

    assert_equal [
      { type: :has_one, name: 'latest_post', class_name: 'Post', serializer: PostSerializer },
    ], Rtypes::Analyzer.new(HasOne::UserSerializer).associations

    assert_equal [], Rtypes::Analyzer.new(NonExistsAssociation::UserSerializer).associations

    assert_nil Rtypes::Analyzer.new(NonExistModelSerializer).associations
  end

  test 'nested_serializers' do
    assert_equal [Nest::UserSerializer::PostSerializer], Rtypes::Analyzer.new(Nest::UserSerializer).nested_serializers
    assert_equal [], Rtypes::Analyzer.new(UserSerializer).nested_serializers
    assert_equal [], Rtypes::Analyzer.new(nil).nested_serializers
  end

  test 'parent_serializer' do
    assert_equal Nest::UserSerializer, Rtypes::Analyzer.new(Nest::UserSerializer::PostSerializer).parent_serializer
    assert_nil Rtypes::Analyzer.new(UserSerializer).parent_serializer
    assert_nil Rtypes::Analyzer.new(nil).parent_serializer
  end

end
