require 'minitest/autorun'
require_relative './test_helper'

class TestMemosOnFilesystem < Minitest::Test
  def test_memos_default
    assert_equal Dir.glob('memos/**/*.md').size, 2
  end
end
