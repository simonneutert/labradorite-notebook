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
    assert_includes(@yaml_data_as_struct.public_methods, :id)
    assert_includes(@yaml_data_as_struct.public_methods, :title)
    assert_includes(@yaml_data_as_struct.public_methods, :tags)
    assert_includes(@yaml_data_as_struct.public_methods, :urls)
    assert_includes(@yaml_data_as_struct.public_methods, :updated_at)
    assert_kind_of(FileOperations::MetaStruct, @yaml_data_as_struct)
    assert_equal('2021/08/21/hgfe-dcba', @yaml_data_as_struct.id)
    assert_equal('Facts about Pugs!', @yaml_data_as_struct.title)
    assert_equal('dog,pug,pet', @yaml_data_as_struct.tags)
    assert_kind_of(Array, @yaml_data_as_struct.urls)
    assert_equal('http://localhost:9292/memos/2022/09/26/abcd-efgh/edit', @yaml_data_as_struct.urls.first)
    assert_kind_of(DateTime, @yaml_data_as_struct.updated_at)
  end

  def test_yaml_serialiazation_from_string
    assert_kind_of(Hash, @yaml_data_from_string)
    assert(@yaml_data_from_string['id'], '2021/08/21/hgfe-dcba')
    assert_equal('Facts about Pugs!', @yaml_data_from_string['title'])
    assert_equal('dog,pug,pet', @yaml_data_from_string['tags'])
    assert_kind_of(Array, @yaml_data_from_string['urls'])
    assert_equal('http://localhost:9292/memos/2022/09/26/abcd-efgh/edit', @yaml_data_from_string['urls'].first)
    assert_kind_of(DateTime, @yaml_data_from_string['updated_at'])
    assert_equal(2021, @yaml_data_from_string['updated_at'].year)
    assert_equal(8, @yaml_data_from_string['updated_at'].month)
    assert_equal(21, @yaml_data_from_string['updated_at'].day)
  end

  def test_yaml_serialiazation_from_file
    assert_kind_of(Hash, @yaml_data_from_demo_file)
    assert_equal('2022/09/26/abcd-efgh', @yaml_data_from_demo_file['id'])
    assert_equal('All about Pugs!!!', @yaml_data_from_demo_file['title'])
    assert_equal('dog,pug,pet', @yaml_data_from_demo_file['tags'])
    assert_kind_of(Array, @yaml_data_from_demo_file['urls'])
    assert_empty(@yaml_data_from_demo_file['urls'])
    assert_kind_of(DateTime, @yaml_data_from_demo_file['updated_at'])
    assert_equal(2022, @yaml_data_from_demo_file['updated_at'].year)
    assert_equal(9, @yaml_data_from_demo_file['updated_at'].month)
    assert_equal(29, @yaml_data_from_demo_file['updated_at'].day)
  end
end
