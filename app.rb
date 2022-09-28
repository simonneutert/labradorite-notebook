# frozen_string_literal: true

class App < Roda
  attr_accessor :index

  plugin :static, ['/js', '/css']
  plugin :render, layout: './layout'
  plugin :view_options
  plugin :json
  plugin :json_parser

  dev = ENV['RACK_ENV'] == 'development'
  begin
    index = Tantiny::Index.new '.tantiny', exclusive_writer: !dev do
      id :id
      facet :category
      string :title
      text :content
      date :updated_at
    end
  rescue StandardError => e
    puts e
  end

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

      r.post 'reload' do
        index = SearchIndex::Core.new(index).recreate_index!

        response.status = 200
        {}
      end

      r.post 'search' do
        Controllers::Memos::Search.new(r, index).run
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
          Controllers::Memos::Update.new(r, index, memo_path, @meta).run!
          # replace redirect with JSON response
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
