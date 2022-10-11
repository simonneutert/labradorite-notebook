# frozen_string_literal: true

class App < Roda
  attr_accessor :index, :index_status

  plugin :static, ['/js', '/css', '/favicon']
  plugin :render, layout: './layout'
  plugin :view_options
  plugin :caching
  plugin :json
  plugin :json_parser
  plugin :sinatra_helpers # , delegate: false

  dev = ENV['RACK_ENV'] == 'development'
  index ||= SearchIndex::Core.init_index
  @index_status = nil

  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  # TODO: write a method for whitelist checks of media type
  media_whitelist = %w[pdf md txt png jpg jpeg]

  route do |r|
    r.root do
      r.redirect '/memos'
    end

    r.on 'api' do
      r.on 'v1' do
        r.on 'memos' do
          r.on 'attachments' do
            r.post do
              data = r.params['file']
              filename = data[:filename]
              raise unless media_whitelist.any? { |t| filename.end_with?(t) }

              pathy_filename = "#{Time.now.to_i}-#{filename}"[1..-1].gsub('/', '_')
              File.write(".#{r.params['path']}/#{pathy_filename}",
                         File.read(data[:tempfile]),
                         mode: 'wb')

              { success: "#{r.params['path']}/#{pathy_filename}" }
            end
          end

          # TODO: make the response dependent to action result
          r.post 'reload' do
            index = SearchIndex::Core.new(index).recreate_index!
            { status: :success }
          end

          # TODO: make the response dependent to action result
          r.post 'search' do
            Controllers::Memos::Search.new(r, index).run
          end

          r.post 'preview' do
            content = r.params['md']
            return { md: '<span></span>' } if content.empty?

            { md: markdown.render(content) }
          end

          r.on(%r{(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})}) do |memo_path|
            @current_path_memo = "/memos/#{memo_path}"
            path_to_memo_md = ".#{@current_path_memo}/memo.md"
            path_to_memo_meta_yml = ".#{@current_path_memo}/meta.yaml"

            markdown_content = File.read(path_to_memo_md)
            @content_md = markdown_content
            @content = markdown.render(markdown_content)

            @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yml)
            @meta_ostruct = FileOperations::MetaDataFileReader.to_ostruct(@meta)

            # TODO: make the response dependent to action result
            r.post 'update' do
              Controllers::Memos::Update.new(r, index, memo_path, @meta).run!
              return { status: :success }
            end
          end
        end
      end
    end

    r.on 'attachments' do
      r.multi_public('attachments')
    end

    r.on 'memos' do
      set_view_subdir 'memos'

      r.on(%r{(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})/(.*\.(jpg|jpeg|png))}) do |x, y|
        # mime_type :jpg
        send_file "./memos/#{x}/#{y}"
      end

      # TODO: extract to controller
      r.on(%r{(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})}) do |memo_path|
        @current_path_memo = "/memos/#{memo_path}"
        path_to_memo_md = ".#{@current_path_memo}/memo.md"
        path_to_memo_meta_yml = ".#{@current_path_memo}/meta.yaml"

        markdown_content = File.read("./#{path_to_memo_md}")
        @content_md = markdown_content
        @content = markdown.render(markdown_content)

        @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yml)
        @meta_ostruct = FileOperations::MetaDataFileReader.to_ostruct(@meta)
        @meta_data_digest = Digest::SHA1.hexdigest(@meta_ostruct.to_yaml)

        @media_files = Dir.glob(".#{@current_path_memo}/**")
                          .filter { |filename| media_whitelist.any? { |t| filename.end_with?(t) } }

        r.on 'destroy' do
          FileOperations::DeleteMemo.new(memo_path, @current_path_memo).run
          r.redirect '/'
        end

        r.on 'edit' do
          view 'edit'
        end

        r.is do
          r.etag(@meta_data_digest)
          view 'show'
        end
      end

      r.on 'new' do
        new_memo = FileOperations::NewMemoGenerator.new
        new_memo.generate
        r.redirect "/#{new_memo.path}/edit"
      rescue StandardError => e
        r.redirect '/memos/new'
      end

      # TODO: extract to controller
      r.is do
        n_files = 25
        files = FileOperations::FilesSortByLatestModified.new.latest_n_memos(n_files)
        @titles_latest = files.map do |post|
          meta_data = YAML.safe_load(File.read("#{post}/meta.yaml"), [Date, Time, DateTime])
          {
            title: meta_data['title'],
            url: "/#{post}"
          }
        end

        view 'index'
      end
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
  end
end
