require 'gli'
module LMCAdm
  include GLI::App
  extend self
  subcommand_option_handling :normal

  desc 'Generic lmc operations'
  command :cloud do |c|
    c.desc 'Check cloud connectivity'
    c.action do |global_options|
      lmcen = LMC::Cloud.instance
      puts "Base URL: #{lmcen.build_url}"
      puts "Cloud connection OK" if lmcen.auth_ok
      if global_options[:v]
        puts "authentication token: " + lmcen.session_token
      end
    end

    c.desc 'Display cloud version information'
    c.command :about do |cloud_about|
      cloud_about.action do |global_options|
        cloud = LMC::Cloud.instance
        #account = cloud.get_account(nil, 'ROOT')
        #puts account.inspect
        #cloud.auth_for_accounts([account.id])
        backstage_infos = cloud.get_backstage_serviceinfos.body.map {|info| { 'serviceId' => info.serviceId,
                                                                              'instanceCount' => info.instanceCount,
                                                                              'versions' => info.versionInfoList.map {|vil| vil['version']}.uniq.join(",")
        }}
        tp backstage_infos
        puts '---'
        puts "Base URL: #{cloud.build_url}"
        puts "Principal: #{LMC::Principal.get_self(cloud)}"

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

    c.arg_name 'account'#, :multiple => true # no support for multiple accounts until the auth_for_accounts api is fixed
    c.desc 'Request auth token'
    c.command :token do |get_token|
      get_token.action do |_g, _o, args|
        accounts = args.map { |a|
          LMC::Account.get_by_uuid_or_name a
        }
        puts LMC::Cloud.instance.session_token if accounts.empty?
        accounts.each { |a|
          a.cloud.auth_for_account a
          puts a.cloud.session_token
        }
      end
      end
    end
  end
