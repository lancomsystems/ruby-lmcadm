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

    c.desc 'View and accept terms of use information'
    c.command :tos do |tos|
      tos.default_desc 'View terms of service'
      tos.action do ||
        begin
          c = LMC::Cloud.instance
          puts "No outstanding terms of service"
        rescue LMC::OutdatedTermsOfUseException => e
          puts e.response
        end
      end
      tos.arg_name 'TOS name', :multiple => true
      tos.desc 'Accept terms of use by name'
      tos.command :accept do |accept|
        accept.action do |global_options, options, args|
        begin
          cloud = LMC::Cloud.instance
        rescue LMC::OutdatedTermsOfUseException => e
            matched_tos = e.missing.select do |missingtos|
              args.include? missingtos['name']
            end
            cloud = LMC::Cloud.instance authorize: false
            puts "Accepting TOS #{matched_tos.to_s}"
            cloud.accept_tos matched_tos
          end
        end
      end
    end
    c.desc 'Change user information'
    c.command :changeuser do |cloud_register|
      cloud_register.switch :password
      cloud_register.action do |global_options, options|
        newdata = {}
        if options[:password]
          newpass = Helpers::read_pw "Enter new password for " + global_options[:user] + ":"
          newpass_confirm = Helpers::read_pw "Confirm password " + global_options[:user] + ":"
          raise 'Mismatch' unless newpass == newpass_confirm
          newdata['password'] = newpass
        end
        user = LMC::User.new(newdata)
        user.update(global_options[:password])
      end
    end
  end
end
