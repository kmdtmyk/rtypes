require "test_helper"

class RtypesAnalyzerTest < ActiveSupport::TestCase

  test 'attributes' do
    analyzer = Rtypes::Analyzer.new(PostSerializer)
    assert_equal [
      { type: :integer, name: :id },
      { type: :string, name: :title },
      { type: :string, name: :body },
    ], analyzer.attributes

    analyzer = Rtypes::Analyzer.new(UserSerializer)
    assert_equal [
      { type: :integer, name: :id },
      { type: :string, name: :name },
      { type: :boolean, name: :admin },
      { type: nil, name: :any, options: { typescript: 'any' } },
    ], analyzer.attributes
  end

end

