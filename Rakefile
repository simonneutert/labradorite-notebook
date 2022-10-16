require 'minitest'
require 'minitest/test_task'

# Minitest::TestTask.create # named test, sensible defaults

Minitest::TestTask.create(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.warning = false
  t.test_globs = ['test/**/*_test.rb']
end

task default: :test

task :reset do
  FileUtils.rm_rf('./memos')
  FileUtils.cp_r('./.defaults/memos', './')
end
