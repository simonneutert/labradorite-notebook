# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestEndpointsApiV1 < Minitest::Test
  OUTER_APP = Rack::Builder.parse_file('config.ru')

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

  def test_memos_tantiny_reload
    post '/api/v1/memos/reload'

    json = JSON.parse(last_response.body)

    assert_equal 'success', json['status']
  end

  # rubocop:disable Layout/LineLength
  def test_memos_tantiny_search
    post '/api/v1/memos/reload'

    post('/api/v1/memos/search', { search: 'pug' })

    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_kind_of Array, json
    assert_equal 2, json.size
    assert_equal 3, json.first.size

    first_result_triplet = json.first

    assert_equal '/memos/2021/08/21/hgfe-dcba', first_result_triplet.first
    assert_equal 'Facts about Pugs!', first_result_triplet[1]
    assert_equal ['The Pug is a breed of dog originally from China, with physically distinctive features of a wrinkly, short-muzzled face and curled tail. The breed has a fine, glossy coat that comes in a variety of colors, most often light brown (fawn) or black, and a compact, square body with well developed and thick muscles all over the body.', '![](/memos/2021/08/21/hgfe-dcba/665507228-pug.jpg)', '[Wikipedia](https://en.wikipedia.org/wiki/Pug)'], first_result_triplet.last
    assert_kind_of Array, first_result_triplet.last
  end
  # rubocop:enable Layout/LineLength

  def test_memos_tantiny_search_without_match
    post '/api/v1/memos/reload'

    post('/api/v1/memos/search', { search: 'pugxxx' })

    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_kind_of Array, json
    assert_equal 0, json.size
    assert_nil json.first
    assert_empty json
  end

  def test_memos_markdown_to_html_preview
    post('/api/v1/memos/preview', { md: '' })
    json = JSON.parse(last_response.body)

    assert_equal '<span></span>', json['md']

    post('/api/v1/memos/preview', { md: '# Labradorite' })
    json = JSON.parse(last_response.body)

    assert_equal "<h1>Labradorite</h1>\n", json['md']
  end

  # rubocop:disable Layout/LineLength
  def test_memos_update_memo
    post('/api/v1/memos/2021/08/21/hgfe-dcba/update', {
           'title' => 'Facts about Pugsies!',
           'tags' => 'dog,pug,pet',
           'content' => "The Pug is a breed of dog originally from China, with physically distinctive features of a wrinkly, short-muzzled face and curled tail. The breed has a fine, glossy coat that comes in a variety of colors, most often light brown (fawn) or black, and a compact, square body with well developed and thick muscles all over the body.\r\n\r\n![](/memos/2021/08/21/hgfe-dcba/665507228-pug.jpg)\r\n\r\n## Second\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nSecond paragraph with a link to a [GitHub](http://localhost:9292/memos/2022/09/26/abcd-efgh/edit) repository.\r\n\r\n### Thirds\r\n\r\nhere are some links to help you\r\n\r\nhttp://localhost:9292/memos/2022/09/25/abcd-efgh/edit\r\n\r\nhttp://localhost:9292/memos/2022/09/24/abcd-efgh/edit\r\n"
         })

    assert_equal 200, last_response.status
    assert_equal 'success', JSON.parse(last_response.body)['status']
  end
  # rubocop:enable Layout/LineLength

  def test_system_database_status # rubocop:disable Metrics/MethodLength
    get '/api/v1/system/database-status'

    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.content_type

    json = JSON.parse(last_response.body)

    # Test top-level response structure
    assert_equal 'ok', json['status']
    assert_includes json, 'timestamp'
    assert_includes json, 'database'
    assert_includes json, 'connection_pool'
    assert_includes json, 'health_check'

    # Test database info structure
    database_info = json['database']

    assert_includes database_info, 'type'
    assert_includes database_info, 'connected'
    assert_includes database_info, 'connection_stats'

    # Test connection pool structure
    connection_pool = json['connection_pool']

    assert_includes connection_pool, 'status'
    assert_includes connection_pool, 'total_operations'

    # Test health check structure
    health_check = json['health_check']

    assert_includes health_check, 'success'
    assert_includes health_check, 'response_time_ms'

    # Test that health check was successful
    assert health_check['success']
    assert_kind_of Numeric, health_check['response_time_ms']
    assert_kind_of Integer, health_check['record_count']
  end
end
