require "test_helper"

class Rtypes::AnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    assert_equal [
      { type: :integer, name: 'id' },
      { type: :string, name: 'title' },
      { type: :string, name: 'body' },
    ], Rtypes::Analyzer.new(PostSerializer).attributes

    assert_equal [
      { type: :integer, name: 'id' },
      { type: :string, name: 'name' },
      { type: :boolean, name: 'admin' },
      { type: nil, name: 'any', options: { typescript: 'any' } },
    ], Rtypes::Analyzer.new(UserSerializer).attributes
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
  end

end

