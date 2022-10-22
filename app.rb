# frozen_string_literal: true

# TODO: write a method for whitelist checks of media type
MEDIA_WHITELIST = %w[txt pdf md png jpg jpeg heic webp yml yaml json]
                  .map { |c| [c.upcase, c] }
                  .flatten
                  .freeze

require 'rack/deflater'
class App < Roda
  use Rack::Deflater

  attr_accessor :index, :index_status

  plugin :static, ['/js', '/css', '/favicon']
  plugin :render, layout: './layout'
  plugin :view_options
  plugin :all_verbs
  plugin :sessions, key: 'labradorite',
                    secret: ENV.delete('SESSION_SECRET') || 'labradoritelabradoritelabradoritelabradoritelabradoritelabradorite'
  plugin :caching
  plugin :json
  plugin :json_parser
  plugin :sinatra_helpers # , delegate: false
  plugin :assets, css: Dir.entries('assets/css').reject { |f| f.size <= 2 },
                  js: Dir.entries('assets/js').reject { |f| f.size <= 2 }

  compile_assets

  dev = ENV['RACK_ENV'] == 'development'
  index ||= SearchIndex::Core.init_index
  controller = Controllers::Memos::Reload.new(index)
  index = controller.recreate_index

  @index_status = nil

  allowed_file_endings_regexp = MEDIA_WHITELIST.join('|').freeze

  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  route do |r|
    r.assets

    r.root do
      r.redirect '/memos'
    end

    r.on 'api' do
      r.on 'v1' do
        r.on 'attachments' do
          pwd_root = Dir.pwd

          r.on(%r{memos/(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})/(.*\.(#{allowed_file_endings_regexp}))}) do |path, filename|
            r.delete do
              file_worker = FileOperations::Attachments::Deleter.new(Dir.pwd, path, filename)
              file_worker.delete
              file_worker.status
            end
          end

          r.post do
            file_worker = FileOperations::FileUpload.new(pwd_root, r.params)
            file_worker.store
            file_worker.status
          end
        end

        r.on 'memos' do
          # TODO: make the response dependent to action result
          r.post 'reload' do
            controller = Controllers::Memos::Reload.new(index)
            index = controller.recreate_index
            controller.status
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
            @meta_ostruct = FileOperations::MetaDataFileReader.hash_to_ostruct(@meta)

            r.on 'destroy' do
              FileOperations::DeleteMemo.new(memo_path, @current_path_memo).run
              r.session['last_file_scan'] = nil
              r.redirect '/'
            end

            # TODO: make the response dependent to action result
            r.post 'update' do
              Controllers::Memos::Update.new(r, index, memo_path, @meta).run!
              r.session['last_file_scan'] = nil
              begin
                `prettier -w #{path_to_memo_md}`
              rescue StandardError
                puts 'Prettier not installed!'
                puts 'Install it by running: `$ npm install -g prettier`'
                return { status: :success, message: 'prettier not on PATH' }
              end
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

      r.on(%r{(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})/(.*\.(#{allowed_file_endings_regexp}))}) do |path, filename|
        # TODO: add a caching soluting, that checks for the requested file's last touch date
        send_file "./memos/#{path}/#{filename}"
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
        @meta_ostruct = FileOperations::MetaDataFileReader.hash_to_ostruct(@meta)
        @meta_data_digest = Digest::SHA1.hexdigest(@meta_ostruct.to_yaml)

        @media_files = Dir.glob(".#{@current_path_memo}/**")
                          .filter { |filename| MEDIA_WHITELIST.any? { |t| filename.downcase.end_with?(t.downcase) } }
                          .reject { |filename| filename.end_with?('memo.md') || filename.end_with?('meta.yaml') }

        r.on 'destroy' do
          FileOperations::DeleteMemo.new(memo_path, @current_path_memo).run
          r.session['last_file_scan'] = nil
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
        r.etag(r.session['last_file_scan'])

        files = FileOperations::FilesSortByLatestModified.new.latest_n_memos_by_file_modified(n_files)

        @titles_latest = files.map do |post|
          meta_data = YAML.safe_load(File.read("#{post}/meta.yaml"), [Date, Time, DateTime])
          {
            title: meta_data['title'],
            url: "/#{post}"
          }
        end
        r.session['last_file_scan'] = Digest::SHA1.hexdigest('1')

        view 'index'
      end
    end
  end
end
