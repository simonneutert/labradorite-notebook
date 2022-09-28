module Controllers
  module Memos
    class Update
      attr_reader :r, :meta, :meta_ostruct, :index

      def initialize(r, index, memo_path, meta)
        @params = Helper::DeepCopy.create(r.params)
        @index = index
        @memo_path = memo_path
        @meta = meta
        @search_input = @params['search']
      end

      def run!
        meta_data = FileOperations::MetaDataParamDeserializer.read(@params)
        meta_updated = Helper::DeepCopy.create(@meta).merge(meta_data)

        @current_path_memo = "/memos/#{@memo_path}"
        path_to_memo_md = ".#{@current_path_memo}/memo.md"
        path_to_memo_meta_yml = ".#{@current_path_memo}/meta.yaml"

        File.write(path_to_memo_meta_yml, meta_updated.to_yaml)
        File.write(path_to_memo_md, @params['content'])

        data = Helper::DeepCopy.create(meta_updated).merge({ 'content' => @params['content'] })

        @index.transaction do
          @index << {
            id: data['id'],
            tags: data['tags'],
            title: data['title'].strip,
            content: data['content'],
            updated_at: DateTime.now
          }
        end
        @index.reload
      end
    end
  end
end
