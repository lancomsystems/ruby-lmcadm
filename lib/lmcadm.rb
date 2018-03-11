#require "lmcadm/version"
#require 'lmcadm/account_commands'
#require 'lmcadm/test_command_container'

Dir.glob(File.expand_path("../lmcadm/*.rb", __FILE__)).each do |file|
  require file
end
module LMCAdm
  # Your code goes here...
end
