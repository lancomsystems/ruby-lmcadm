require 'gli'
module LMCAdm
  include ::GLI::App
  extend self
  #command :cloudiadirect do |c|
  #  c.action do
  #    puts 'direkt!!!!!'
  #  end
  #end
  class TestCommandContainer


    #desc 'Check cloud connectivity'
    #command :cloud do |c|
    #  c.action do |global_options|
    #    lmcen = LMC::Cloud.new(global_options[:cloud_host], global_options[:user], global_options[:password])
    #    puts "Base URL: #{lmcen.build_url}"
    #    puts "Cloud connection OK" if lmcen.auth_ok
    #    if global_options[:v]
    #      puts "authentication token: " + lmcen.session_token
    #    end
    #  end
    #end
  end
end