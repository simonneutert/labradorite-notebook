# frozen_string_literal: true

class App < Roda
  plugin :static, ['/js', '/css']
  plugin :render, layout: './layout'
  plugin :view_options
  plugin :json
  plugin :json_parser

  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

  route do |r|
    r.root do
      r.redirect '/memos'
    end

    r.on 'users' do
      set_view_subdir 'users'

      r.is do
        view 'index'
      end

      r.get(%r{\d{4}/\d{2}/\d{2}/\w{4}-\w{4}}i) do |_id|
        append_view_subdir 'profile'
        view 'index' # uses ./views/users/profile/index.erb
      end
    end

    r.on 'memos' do
      set_view_subdir 'memos'

      r.post 'search' do
        results = INDEX.search(r.params['search'])
        content = results.map do |path_to_memo_md|
          url = "/memos/#{path_to_memo_md}"
          path = "./memos/#{path_to_memo_md}/memo.md"
          path_to_memo_meta_yml = "./memos/#{path_to_memo_md}/meta.yaml"
          @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yml)
          @meta_ostruct = FileOperations::MetaDataFileReader.to_ostruct(@meta)
          markdown_content = File.read(path).scan(/.{0,40}#{r.params['search']}.{0,40}/i)
          [url, @meta_ostruct.title, markdown_content]
        end
        content
      end

      r.on(%r{(\d{4}/\d{2}/\d{2}/\w{4}-\w{4})}) do |memo_path|
        @current_path_memo = "/memos/#{memo_path}"
        path_to_memo_md = ".#{@current_path_memo}/memo.md"
        path_to_memo_meta_yml = ".#{@current_path_memo}/meta.yaml"

        markdown_content = File.read(path_to_memo_md)
        @content_md = markdown_content
        @content = markdown.render(markdown_content)

        @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yml)
        @meta_ostruct = FileOperations::MetaDataFileReader.to_ostruct(@meta)

        r.on 'edit' do
          view 'edit'
        end

        r.post 'update' do
          params = r.params
          meta_data = FileOperations::MetaDataParamDeserializer.read(params)
          meta_updated = Helper::DeepCopy.create(@meta).merge(meta_data)

          File.write(path_to_memo_meta_yml, meta_updated.to_yaml)
          File.write(path_to_memo_md, params['content'])

          INDEX.transaction do
            INDEX << {
              id: meta_updated['id'],
              facet: meta_updated['tags'].join('/'),
              title: meta_updated['title'].strip,
              content: params['content'],
              updated_at: DateTime.now
            }
          end
          INDEX.reload

          r.redirect "#{@current_path_memo}/edit"
        end

        r.is do
          view 'show'
        end
      end

      r.is do
        paths = Dir.glob('memos/**/**').filter do |paths|
                  paths.match(/\.md/)
                end.map! { |file_path| File.dirname(file_path) }

        @titles = paths.map do |post|
          {
            title: YAML.safe_load(File.read("#{post}/meta.yaml"))['title'],
            url: "/#{post}"
          }
        end

        view 'index'
      end
    end
  end
end
