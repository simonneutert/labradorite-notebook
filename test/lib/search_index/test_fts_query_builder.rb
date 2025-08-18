# frozen_string_literal: true

require 'test_helper'

class TestFtsQueryBuilder < Minitest::Test
  def setup
    @builder = SearchIndex::FtsQueryBuilder.new
  end

  def test_build_field_query_with_single_term_single_field
    result = @builder.build_field_query(['title'], 'ruby')
    expected = '(title:ruby OR title:ruby*)'

    assert_equal expected, result
  end

  def test_build_field_query_with_single_term_multiple_fields
    result = @builder.build_field_query(%w[title content], 'ruby')
    expected = '(title:ruby OR title:ruby* OR content:ruby OR content:ruby*)'

    assert_equal expected, result
  end

  def test_build_field_query_with_multiple_terms_single_field
    result = @builder.build_field_query(['title'], 'ruby programming')
    expected = '(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)'

    assert_equal expected, result
  end

  def test_build_field_query_with_multiple_terms_multiple_fields
    result = @builder.build_field_query(%w[title tags], 'ruby web')
    expected = '(title:ruby OR title:ruby* OR tags:ruby OR tags:ruby*) AND ' \
               '(title:web OR title:web* OR tags:web OR tags:web*)'

    assert_equal expected, result
  end

  def test_build_field_query_with_three_fields_and_three_terms
    result = @builder.build_field_query(%w[title tags content], 'ruby web framework')
    expected = '(title:ruby OR title:ruby* OR tags:ruby OR tags:ruby* OR content:ruby OR content:ruby*) AND ' \
               '(title:web OR title:web* OR tags:web OR tags:web* OR content:web OR content:web*) AND ' \
               '(title:framework OR title:framework* OR tags:framework OR tags:framework* OR ' \
               'content:framework OR content:framework*)'

    assert_equal expected, result
  end

  def test_build_field_query_sanitizes_quotes
    result = @builder.build_field_query(['title'], 'ruby "programming"')
    expected = '(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)'

    assert_equal expected, result
  end

  def test_build_field_query_sanitizes_single_quotes
    result = @builder.build_field_query(['title'], "ruby 'programming'")
    expected = '(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)'

    assert_equal expected, result
  end

  def test_build_field_query_removes_special_characters
    result = @builder.build_field_query(['title'], 'ruby(){}[] programming')
    expected = '(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)'

    assert_equal expected, result
  end

  def test_build_field_query_handles_extra_whitespace
    result = @builder.build_field_query(['title'], '  ruby    programming  ')
    expected = '(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)'

    assert_equal expected, result
  end

  def test_build_field_query_raises_on_empty_fields
    assert_raises(ArgumentError) do
      @builder.build_field_query([], 'ruby')
    end
  end

  def test_build_field_query_raises_on_nil_fields
    assert_raises(ArgumentError) do
      @builder.build_field_query(nil, 'ruby')
    end
  end

  def test_build_field_query_raises_on_blank_query
    assert_raises(ArgumentError) do
      @builder.build_field_query(['title'], '')
    end
  end

  def test_build_field_query_raises_on_nil_query
    assert_raises(ArgumentError) do
      @builder.build_field_query(['title'], nil)
    end
  end

  def test_build_field_query_raises_on_whitespace_only_query
    assert_raises(ArgumentError) do
      @builder.build_field_query(['title'], '   ')
    end
  end

  def test_build_general_query_with_single_term
    result = @builder.build_general_query('ruby')
    expected = 'ruby*'

    assert_equal expected, result
  end

  def test_build_general_query_with_multiple_terms
    result = @builder.build_general_query('ruby programming')
    expected = 'ruby* AND programming*'

    assert_equal expected, result
  end

  def test_build_general_query_with_three_terms
    result = @builder.build_general_query('ruby web framework')
    expected = 'ruby* AND web* AND framework*'

    assert_equal expected, result
  end

  def test_build_general_query_sanitizes_quotes
    result = @builder.build_general_query('ruby "programming"')
    expected = 'ruby* AND programming*'

    assert_equal expected, result
  end

  def test_build_general_query_handles_extra_whitespace
    result = @builder.build_general_query('  ruby    programming  ')
    expected = 'ruby* AND programming*'

    assert_equal expected, result
  end

  def test_build_general_query_raises_on_blank_query
    assert_raises(ArgumentError) do
      @builder.build_general_query('')
    end
  end

  def test_build_general_query_raises_on_nil_query
    assert_raises(ArgumentError) do
      @builder.build_general_query(nil)
    end
  end

  def test_build_general_query_raises_on_whitespace_only_query
    assert_raises(ArgumentError) do
      @builder.build_general_query('   ')
    end
  end

  def test_build_field_query_returns_empty_string_for_query_with_only_special_chars
    result = @builder.build_field_query(['title'], '"(){}[]"')
    expected = ''

    assert_equal expected, result
  end

  def test_build_general_query_returns_empty_string_for_query_with_only_special_chars
    result = @builder.build_general_query('"(){}[]"')
    expected = ''

    assert_equal expected, result
  end

  def test_complex_real_world_queries
    # Test a realistic search scenario
    result = @builder.build_field_query(%w[title content tags], 'Ruby on Rails tutorial')
    expected_parts = [
      '(title:Ruby OR title:Ruby* OR content:Ruby OR content:Ruby* OR tags:Ruby OR tags:Ruby*)',
      '(title:on OR title:on* OR content:on OR content:on* OR tags:on OR tags:on*)',
      '(title:Rails OR title:Rails* OR content:Rails OR content:Rails* OR tags:Rails OR tags:Rails*)',
      '(title:tutorial OR title:tutorial* OR content:tutorial OR content:tutorial* OR tags:tutorial OR tags:tutorial*)'
    ]
    expected = expected_parts.join(' AND ')

    assert_equal expected, result
  end

  def test_query_with_mixed_case_and_punctuation
    result = @builder.build_field_query(['title'], 'Ruby-on-Rails, JavaScript!')
    # Should handle punctuation and preserve case
    assert_includes result, 'title:Ruby-on-Rails'
    assert_includes result, 'title:JavaScript!'
  end
end
