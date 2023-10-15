# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'

class TestMetaDataSerializing < Minitest::Test
  def yaml_string
    '
---
id: 2021/08/21/hgfe-dcba
title: Facts about Pugs!
tags: dog,pug,pet
urls:
- http://localhost:9292/memos/2022/09/26/abcd-efgh/edit
- http://localhost:9292/memos/2022/09/25/abcd-efgh/edit
- http://localhost:9292/memos/2022/09/24/abcd-efgh/edit
updated_at: !ruby/object:DateTime 2021-08-21 17:29:58.161601000 +02:00
'
  end

  def setup
    `rake reset_default_memos`
    @yaml_data_from_string =
      FileOperations::MetaDataFileReader.to_yaml(yaml_string)
    @yaml_data_as_struct =
      FileOperations::MetaDataFileReader.hash_to_struct(@yaml_data_from_string)
    @yaml_data_from_demo_file =
      FileOperations::MetaDataFileReader.from_path('./memos/2022/09/26/abcd-efgh/meta.yaml')
  end

  def after_teardown
    `rake reset_memos`
  end

  def test_meta_struct
    assert(@yaml_data_as_struct.public_methods.include?(:id))
    assert(@yaml_data_as_struct.public_methods.include?(:title))
    assert(@yaml_data_as_struct.public_methods.include?(:tags))
    assert(@yaml_data_as_struct.public_methods.include?(:urls))
    assert(@yaml_data_as_struct.public_methods.include?(:updated_at))
    assert(@yaml_data_as_struct.is_a?(FileOperations::MetaStruct))
    assert_equal(@yaml_data_as_struct.id, '2021/08/21/hgfe-dcba')
    assert_equal(@yaml_data_as_struct.title, 'Facts about Pugs!')
    assert_equal(@yaml_data_as_struct.tags, 'dog,pug,pet')
    assert(@yaml_data_as_struct.urls.is_a?(Array))
    assert_equal(@yaml_data_as_struct.urls.first, 'http://localhost:9292/memos/2022/09/26/abcd-efgh/edit')
    assert(@yaml_data_as_struct.updated_at.is_a?(DateTime))
  end

  def test_yaml_serialiazation_from_string
    assert(@yaml_data_from_string.is_a?(Hash))
    assert(@yaml_data_from_string['id'], '2021/08/21/hgfe-dcba')
    assert_equal(@yaml_data_from_string['title'], 'Facts about Pugs!')
    assert_equal(@yaml_data_from_string['tags'], 'dog,pug,pet')
    assert(@yaml_data_from_string['urls'].is_a?(Array))
    assert_equal(@yaml_data_from_string['urls'].first, 'http://localhost:9292/memos/2022/09/26/abcd-efgh/edit')
    assert(@yaml_data_from_string['updated_at'].is_a?(DateTime))
    assert_equal(@yaml_data_from_string['updated_at'].year, 2021)
    assert_equal(@yaml_data_from_string['updated_at'].month, 8)
    assert_equal(@yaml_data_from_string['updated_at'].day, 21)
  end

  def test_yaml_serialiazation_from_file
    assert(@yaml_data_from_demo_file.is_a?(Hash))
    assert_equal(@yaml_data_from_demo_file['id'], '2022/09/26/abcd-efgh')
    assert_equal(@yaml_data_from_demo_file['title'], 'All about Pugs!!!')
    assert_equal(@yaml_data_from_demo_file['tags'], 'dog,pug,pet')
    assert(@yaml_data_from_demo_file['urls'].is_a?(Array))
    assert(@yaml_data_from_demo_file['urls'].empty?)
    assert(@yaml_data_from_demo_file['updated_at'].is_a?(DateTime))
    assert_equal(@yaml_data_from_demo_file['updated_at'].year, 2022)
    assert_equal(@yaml_data_from_demo_file['updated_at'].month, 9)
    assert_equal(@yaml_data_from_demo_file['updated_at'].day, 29)
  end
end
