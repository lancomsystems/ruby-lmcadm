require "test_helper"
require 'lmc'
class LmcadmTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LMCAdm::VERSION
  end

  def test_find_device_helper
    one = Fixtures.device({'id' => '923d7190-697d-4f06-a2ab-3048c4624f4a', 'status' => { 'name' => 'one'}})
    two = Fixtures.device({'id' => '30204a0e-c95d-445f-8b5c-6dfcb3fe6e08', 'status' => {'name' => 'two'}})
    dup1 = Fixtures.device({'id' => 'c5df8477-6f5b-4f73-844d-179f9f239027', 'status' => {'name' => 'dup'}})
    dup2 = Fixtures.device({'id' => '7dcb59f6-48dd-4f21-98b5-579eb138573e', 'status' => {'name' => 'dup'}})
    devices = [one, two]
    found_one = ::LMCAdm::Helpers.find_device devices, name: 'one'
    found_two = ::LMCAdm::Helpers.find_device devices, id: two.id
    found_one_by_any = LMCAdm::Helpers.find_device devices, name: 'one', id: 'one'

    assert_equal one, found_one
    assert_equal two, found_two
    assert_equal one, found_one_by_any
    assert_raises Exception do
      ::LMCAdm::Helpers.find_device devices, name: 'none'
    end
    e = assert_raises Exception do
      ::LMCAdm::Helpers.find_device devices, name: 'dup'
    end
    assert_equal 'Device not found: dup ', e.message
  end

  def test_arg_helper
    args = []
    e = assert_raises RuntimeError do
      LMCAdm::Helpers.ensure_arg args
    end
    assert_equal 'Argument missing: No argument specified.', e.message
    e = assert_raises RuntimeError do
      LMCAdm::Helpers.ensure_arg args, kind: 'nothing'
    end
    assert_equal 'Argument missing: No nothing specified.', e.message
    e = assert_raises RuntimeError do
      LMCAdm::Helpers.ensure_arg args, message: 'Idiot!'
    end
    assert_equal 'Idiot!', e.message
    good_args = ['hello']
    assert_equal good_args, LMCAdm::Helpers.ensure_arg(good_args, kind: 'Greeting')
  end
end
