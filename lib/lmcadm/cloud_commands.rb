require 'gli'
module LMCAdm
  include GLI::App
  extend self
  subcommand_option_handling :normal

  desc 'Generic lmc operations'
  command :cloud do |c|
    c.desc 'Check cloud connectivity'
    c.action do |global_options|
      lmcen = LMC::Cloud.new(global_options[:cloud_host], global_options[:user], global_options[:password])
      puts "Base URL: #{lmcen.build_url}"
      puts "Cloud connection OK" if lmcen.auth_ok
      if global_options[:v]
        puts "authentication token: " + lmcen.session_token
      end
    end
    c.command :about do |cloud_about|
      cloud_about.action do |global_options|
        cloud = LMC::Cloud.instance
        #account = cloud.get_account(nil, 'ROOT')
        #puts account.inspect
        #cloud.auth_for_accounts([account.id])
        backstage_infos = cloud.get_backstage_serviceinfos.body.map {|info| {'serviceId' => info.serviceId,
                                                                             'instanceCount' => info.instanceCount,
                                                                             'versions' => info.versionInfoList.map {|vil| vil['version']}.uniq.join(",")
        }}
        tp backstage_infos

      end
    end
    c.desc 'Change user information'
    c.command :changeuser do |cloud_register|
      cloud_register.switch :password
      cloud_register.action do |global_options, options|
        newdata = {}
        if options[:password]
          puts "Enter new password for " + global_options[:user] + ":"
          newpass = STDIN.noecho(&:gets).strip
          puts "Confirm password " + global_options[:user] + ":"
          newpass_confirm = STDIN.noecho(&:gets).strip
          raise 'Mismatch' unless newpass == newpass_confirm
          newdata['password'] = newpass
        end
        user = LMC::User.new(newdata)
        user.update(global_options[:password])
      end
    end
  end
end