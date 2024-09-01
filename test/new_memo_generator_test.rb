# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/file_operations/new_memo_generator'

class NewMemoGeneratorTest < Minitest::Test
  def setup
    @generator = FileOperations::NewMemoGenerator.new
    @datetime_now = DateTime.now
    @slug = 'test-slug'
  end

  def test_generate_title
    month = @datetime_now.month.to_s.rjust(2, '0')
    day = @datetime_now.day.to_s.rjust(2, '0')

    expected_title_with_slug = "#{@datetime_now.year}-#{month}-#{day}-#{@slug}"

    assert_equal expected_title_with_slug, @generator.send(:generate_title, @datetime_now, @slug)

    expected_title_without_slug = "#{@datetime_now.year}-#{month}-#{day}"

    assert_equal expected_title_without_slug, @generator.send(:generate_title, @datetime_now, nil)
  end

  def test_path_id
    expected_path_id = "#{@datetime_now.year}/#{@datetime_now.month}/#{@datetime_now.day}/#{@slug}"

    assert_equal expected_path_id, @generator.send(:path_id, @datetime_now, @slug)
  end

  def test_meta_yaml
    expected_yaml = {
      'id' => @generator.send(:path_id, @datetime_now, @slug),
      'title' => @generator.send(:generate_title, @datetime_now, @slug),
      'tags' => '',
      'urls' => [],
      'updated_at' => @datetime_now
    }.to_yaml.to_s

    assert_equal(
      expected_yaml,
      @generator.send(
        :meta_yaml, @datetime_now, @generator.send(:generate_title, @datetime_now, @slug), @slug
      )
    )
  end

  def test_generate # rubocop:disable Minitest/MultipleAssertions
    # Mocking the SimpleUidGenerator to return a predictable slug

    generated_path = @generator.generate
    slug = @generator.slug
    expected_path = "memos/#{@generator.send(:path_id, @datetime_now, slug)}"

    assert_equal expected_path, generated_path

    # Check if the directories and files are created
    assert Dir.exist?(expected_path)
    assert_path_exists "#{expected_path}/memo.md"
    assert_path_exists "#{expected_path}/meta.yaml"

    # Clean up after the test
    FileUtils.rm_rf(expected_path)
  end
end
