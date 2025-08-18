# frozen_string_literal: true

require_relative '../../helper/memo_path'

module Controllers
  module Memos
    class Update
      attr_reader :r, :meta, :meta_struct, :index

      def initialize(req, index, memo_path, meta)
        @params = Helper::DeepCopy.create(req.params)
        @index = index
        @memo_path = memo_path
        @meta = meta
        @search_input = @params['search']
      end

      def run! # rubocop:disable Metrics/AbcSize, Naming/PredicateMethod
        meta_data = FileOperations::MetaDataParamDeserializer.read(@params)
        meta_updated = Helper::DeepCopy.create(@meta)
                                       .merge(meta_data)
                                       .merge('updated_at' => DateTime.now)

        memo_path = Helper::MemoPath.new(@memo_path)
        path_to_memo_md = memo_path.memo_file_path
        path_to_memo_meta_yml = memo_path.meta_file_path

        File.write(path_to_memo_meta_yml, meta_updated.to_yaml)
        File.write(path_to_memo_md, @params['content'])

        memo_schema = Helper::DeepCopy.create(meta_updated)
                                      .merge('content' => @params['content'])

        upsert!(memo_schema)
        @index.reload
        true
      end

      private

      def upsert!(data)
        @index.transaction do
          @index.add_memo({
                            id: data['id'],
                            tags: data['tags'],
                            title: data['title'].strip,
                            content: data['content'],
                            updated_at: DateTime.now
                          })
        end
      end
    end
  end
end
