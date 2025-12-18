require "test_helper"

class Rtypes::AnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    analyzer = Rtypes::Analyzer.new(PostSerializer)
    assert_equal [
      { type: :integer, name: 'id' },
      { type: :string, name: 'title' },
      { type: :string, name: 'body' },
    ], analyzer.attributes

    analyzer = Rtypes::Analyzer.new(UserSerializer)
    assert_equal [
      { type: :integer, name: 'id' },
      { type: :string, name: 'name' },
      { type: :boolean, name: 'admin' },
      { type: nil, name: 'any', options: { typescript: 'any' } },
    ], analyzer.attributes
  end

  test 'associations' do
    analyzer = Rtypes::Analyzer.new(PostSerializer)
    assert_equal [
      { type: :belongs_to, name: 'user', class_name: 'User', serializer: UserSerializer },
      { type: :belongs_to, name: 'delete_user', class_name: 'User', serializer: UserSerializer },
      { type: :has_many, name: 'comments', class_name: 'Comment', serializer: nil },
    ], analyzer.associations

    analyzer = Rtypes::Analyzer.new(UserSerializer)
    assert_equal [
      { type: :has_many, name: 'posts', class_name: 'Post', serializer: PostSerializer },
      { type: :has_one, name: 'latest_post', class_name: 'Post', serializer: PostSerializer },
    ], analyzer.associations
  end

end

