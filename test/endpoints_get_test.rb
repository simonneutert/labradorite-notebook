# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestEndpointsGet < Minitest::Test
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

  def test_index_redirect
    get '/'

    assert_equal 302, last_response.status
  end

  def test_memos_index
    get '/memos'

    assert_equal 200, last_response.status
  end

  def test_memos_show
    get '/memos/2021/08/21/hgfe-dcba'

    assert_equal 200, last_response.status
  end

  def test_memos_edit
    get '/memos/2021/08/21/hgfe-dcba/edit'

    assert_equal 200, last_response.status
  end

  def test_memos_delete_or_destroy
    get '/memos/2021/08/21/hgfe-dcba/destroy'

    assert_equal 302, last_response.status
    assert_equal 6, Dir.glob('memos/**/*/').size
  end
end
