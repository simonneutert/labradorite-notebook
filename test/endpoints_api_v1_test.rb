require 'minitest/autorun'
require_relative './test_helper'

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
    assert_equal json['status'], 'success'
  end

  def test_memos_tantiny_search
    post '/api/v1/memos/reload'

    post('/api/v1/memos/search', { search: 'pug' })

    json = JSON.parse(last_response.body)
    assert_equal last_response.status, 200
    assert_kind_of Array, json
    assert_equal json.size, 2
    assert_equal json.first.size, 3

    first_result_triplet = json.first

    assert_equal '/memos/2021/08/21/hgfe-dcba', first_result_triplet.first
    assert_equal 'Facts about Pugs!', first_result_triplet[1]
    assert_equal ["The Pug is a breed of dog originally from China, with physically distinctive features of a wrinkly, short-muzzled face and curled tail. The breed has a fine, glossy coat that comes in a variety of colors, most often light brown (fawn) or black, and a compact, square body with well developed and thick muscles all over the body.\r",
                  "![](/memos/2021/08/21/hgfe-dcba/665507228-pug.jpg)\r"], first_result_triplet.last
    assert_kind_of Array, first_result_triplet.last
  end

  def test_memos_tantiny_search_without_match
    post '/api/v1/memos/reload'

    post('/api/v1/memos/search', { search: 'pugxxx' })

    json = JSON.parse(last_response.body)
    assert_equal last_response.status, 200
    assert_kind_of Array, json
    assert_equal json.size, 0
    assert_nil json.first
    assert json.empty?
  end

  def test_memos_markdown_to_html_preview
    post('/api/v1/memos/preview', { md: '' })
    json = JSON.parse(last_response.body)

    assert_equal json['md'], '<span></span>'

    post('/api/v1/memos/preview', { md: '# Labradorite' })
    json = JSON.parse(last_response.body)

    assert_equal json['md'], "<h1>Labradorite</h1>\n"
  end

  def test_memos_update_memo
    post('/api/v1/memos/2021/08/21/hgfe-dcba/update', { 'title' => 'Facts about Pugsies!',
                                                        'tags' => 'dog,pug,pet',
                                                        'content' =>
       "The Pug is a breed of dog originally from China, with physically distinctive features of a wrinkly, short-muzzled face and curled tail. The breed has a fine, glossy coat that comes in a variety of colors, most often light brown (fawn) or black, and a compact, square body with well developed and thick muscles all over the body.\r\n\r\n![](/memos/2021/08/21/hgfe-dcba/665507228-pug.jpg)\r\n\r\n## Second\r\n\r\nSecond paragraph with a link to a [GitHub](http://localhost:9292/memos/2022/09/26/abcd-efgh/edit) repository.\r\n\r\n### Thirds\r\n\r\nhere are some links to help you\r\n\r\nhttp://localhost:9292/memos/2022/09/25/abcd-efgh/edit\r\n\r\nhttp://localhost:9292/memos/2022/09/24/abcd-efgh/edit\r\n" })

    assert_equal last_response.status, 200
    assert_equal JSON.parse(last_response.body)['status'], 'success'
  end
end
