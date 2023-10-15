# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestSimpleUidGenerator < Minitest::Test
  def setup
    @simple_uid = Helper::SimpleUidGenerator.generate
  end

  def test_uid_pattern
    assert @simple_uid.match?(/^\w{4}-\w{4}$/)
  end
end
