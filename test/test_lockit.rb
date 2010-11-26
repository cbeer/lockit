require 'helper'

class MockLockitDir
  include LockIt::Mixin

  def path
    '.'
  end

  def test_lock_content args = {}
    lock_content args
  end
  def test_lock_file
    lock_file
  end


end
class TestLockit < Test::Unit::TestCase
  def test_lock_name
    d = MockLockitDir.new

    assert_equal(d.test_lock_file, './lock.txt')
  end
  def test_lock_content
    d = MockLockitDir.new

    str = d.test_lock_content

    assert_match /[^ ]+ \d+/, str

  end
end
