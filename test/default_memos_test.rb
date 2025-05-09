# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestMemosOnFilesystem < Minitest::Test
  def test_memos_default
    assert_equal 2, Dir.glob('.defaults/memos/**/*.md').size
  end
end
