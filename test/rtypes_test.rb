require "test_helper"

class RtypesTest < ActiveSupport::TestCase

  def setup
    Rtypes.instance_variable_set(:@config, nil)
  end

  test "it has a version number" do
    assert Rtypes::VERSION
  end

  test 'config' do
    assert_equal 'app/javascript/types', Rtypes.config.path
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal 'app/frontend/entrypoints/types', Rtypes.config.path
  end

  test 'name_to_serializer' do
    assert_equal UserSerializer, Rtypes.name_to_serializer('user')
    assert_equal UserSerializer, Rtypes.name_to_serializer('User')
    assert_equal UserSerializer, Rtypes.name_to_serializer('UserSerializer')
    assert_equal Namespace2::UserSerializer, Rtypes.name_to_serializer('Namespace2::UserSerializer')
    assert_nil Rtypes.name_to_serializer('foo')
    assert_nil Rtypes.name_to_serializer(nil)
  end

  test 'path_to_serializer' do
    assert_equal UserSerializer, Rtypes.path_to_serializer('/app/test/dummy/app/serializers/user_serializer.rb')
    assert_equal Namespace2::UserSerializer, Rtypes.path_to_serializer('/app/test/dummy/app/serializers/namespace2/user_serializer.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/user_serializer copy.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/dummy_serializer.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/README.md')
    assert_nil Rtypes.path_to_serializer(nil)
  end

  test 'serializer_to_path' do
    skip if ENV['CI']
    assert_equal '/app/test/dummy/app/serializers/user_serializer.rb', Rtypes.serializer_to_path(UserSerializer)
    assert_equal '/app/test/dummy/app/serializers/api/user_serializer.rb', Rtypes.serializer_to_path(Api::UserSerializer)
    assert_nil Rtypes.serializer_to_path(nil)
  end

  test 'path_to_delete_file_path' do
    assert_equal '/app/test/dummy/app/javascript/types/User.ts', Rtypes.path_to_delete_file_path('/app/test/dummy/app/serializers/user_serializer.rb')
    assert_equal '/app/test/dummy/app/javascript/types/namespace2/User.ts', Rtypes.path_to_delete_file_path('/app/test/dummy/app/serializers/namespace2/user_serializer.rb')
    Rtypes.config.path = 'app/frontend/entrypoints/types'
    assert_equal '/app/test/dummy/app/frontend/entrypoints/types/User.ts', Rtypes.path_to_delete_file_path('/app/test/dummy/app/serializers/user_serializer.rb')
    assert_nil Rtypes.path_to_serializer('/app/test/dummy/app/serializers/README.md')
    assert_nil Rtypes.path_to_delete_file_path(nil)
  end

end
