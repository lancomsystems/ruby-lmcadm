require "bundler/gem_tasks"
require "rake/testtask"
require 'rdoc/task'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  #rdoc.main = "README.rdoc"
  #rdoc.rdoc_files.include("lib/lmcadm/helpers/args_helpers.rb")
end
task :default => :test
