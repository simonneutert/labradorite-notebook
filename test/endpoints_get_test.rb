# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestEndpointsGet < Minitest::Test
  OUTER_APP = Rack::Builder.parse_file('config.ru')
  MEMO_ID = 'hgfe-dcba'
  SEARCH_TERM_PUG = 'pug'

  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def setup
    `rake reset_default_memos`
    @app = app
  end

  def after_teardown
    `rake reset_memos`
  end

  def test_index_redirect
    get '/'

    assert_equal 302, last_response.status
  end

  def test_memos_index
    get '/memos'

    assert_equal 200, last_response.status
  end

  def test_memos_show
    get "/memos/2021/08/21/#{MEMO_ID}"

    assert_equal 200, last_response.status
  end

  def test_memos_edit
    get "/memos/2021/08/21/#{MEMO_ID}/edit"

    assert_equal 200, last_response.status
  end

  def test_memos_delete_or_destroy
    get "/memos/2021/08/21/#{MEMO_ID}/destroy"

    assert_equal 302, last_response.status
    assert_equal 6, Dir.glob('memos/**/*/').size
  end

  def test_memo_deletion_removes_from_search_index
    # Setup: Reload index to ensure test memo is indexed
    post '/api/v1/memos/reload'

    # Verify memo exists in search before deletion
    post('/api/v1/memos/search', { search: SEARCH_TERM_PUG })
    json_before = JSON.parse(last_response.body)

    assert_operator json_before.size, :>, 0, 'Test memo should be found in search before deletion'

    # Find the specific memo we're going to delete
    target_memo = json_before.find { |result| result[0].include?(MEMO_ID) }

    refute_nil target_memo, 'Target memo should exist in search results'

    # Delete the memo via web route
    get "/memos/2021/08/21/#{MEMO_ID}/destroy"

    assert_equal 302, last_response.status

    # Verify memo is removed from search index
    post('/api/v1/memos/search', { search: SEARCH_TERM_PUG })
    json_after = JSON.parse(last_response.body)

    deleted_memo_still_exists = json_after.any? { |result| result[0].include?(MEMO_ID) }

    refute deleted_memo_still_exists, 'Deleted memo should not appear in search results'
  end

  def test_search_all_page_and_htmx_results
    # Test 1: Full page renders with query
    get '/memos/search-all?q=pug'

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Search All Memos'
    assert_includes last_response.body, 'pug'

    # Test 2: HTMX partial endpoint returns results
    get '/memos/search-all/results?q=pug'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<html>' # No layout
    # Should contain at least one of the pug memos
    assert(last_response.body.include?(MEMO_ID) || last_response.body.include?('abcd-efgh'),
           'Should contain at least one pug-related memo')
  end
end
