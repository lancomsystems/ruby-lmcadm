source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in lmcadm.gemspec
gemspec
if ENV['LMCADM_PATH_DEP'] == "1" #File.directory? '../ruby-lmc'
    gem 'lmc', :path => '../ruby-lmc/'
end
