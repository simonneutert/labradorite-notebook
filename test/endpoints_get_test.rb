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
    assert_equal last_response.status, 302
  end

  def test_memos_index
    get '/memos'
    assert_equal last_response.status, 200
  end

  def test_memos_show
    get '/memos/2021/08/21/hgfe-dcba'
    assert_equal last_response.status, 200
  end

  def test_memos_edit
    get '/memos/2021/08/21/hgfe-dcba/edit'
    assert_equal last_response.status, 200
  end

  def test_memos_delete_or_destroy
    get '/memos/2021/08/21/hgfe-dcba/destroy'
    assert_equal last_response.status, 302
    assert_equal Dir.glob('memos/**/*/').size, 6
  end
end
