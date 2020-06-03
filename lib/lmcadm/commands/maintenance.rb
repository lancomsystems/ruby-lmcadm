module LMCAdm
  command :maintenance do |maintenance|
    maintenance.arg_name 'UUID'
    maintenance.desc 'Resync license status in devices service for an account'
    maintenance.command :licenseresync do |resync|
      resync.action do |global_options, options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        result = cloud.post ['cloud-service-devices', 'maintenance', 'licenses', 'resync'], {'accountId' => args[0]}
      end
    end

    maintenance.arg_name 'UUID', [:required]
    maintenance.desc 'Enable scripting for an account'
    maintenance.command :scripting do |scr|
      scr.desc 'Change the state of scripting'
      scr.switch :enable
      scr.desc 'Get the state of scripting'
      scr.switch :get
      scr.action do |global_options, options, args|
        raise "No account UUID specified" if args.length < 1
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        if options[:get]
          result = cloud.get ['cloud-service-config', 'configroot', 'accounts', args.first, 'scriptauthority']
          puts result.body
        else
          result = cloud.put ['cloud-service-config', 'configroot', 'accounts', args.first, 'scriptauthority'], options[:enable]
          raise "error - unexpected result" unless result.body == options[:enable]
        end
      end
    end

    maintenance.arg_name 'UUID'
    maintenance.desc 'Exempt user from brute force blocking'
    maintenance.command :whitelist do |wl|
      wl.action do |_g, _o, args|
        Helpers.ensure_arg args, kind: 'user uuid'
        cloud = LMC::Cloud.instance
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud.auth_for_account root_account
        # POST /accesscontrol/CLAIMING/whitelist/principals/{principalId}
        url_components = ['cloud-service-devices', 'accesscontrol', 'CLAIMING', 'whitelist', 'principals', args.first]
        cloud.post url_components, {}
      end
    end

    maintenance.arg_name 'UUID', required: true
    maintenance.desc 'Remove entity from blacklist'
    maintenance.command :unblacklist do |unbl|
      unbl.flag 'entity-type', :t, desc: 'Entity type. Choose "principals" or "accounts".', required: true
      unbl.flag 'process-type', :p, desc: 'Process type', default_value: 'CLAIMING'
      unbl.action do |_g, o, args|
        Helpers.ensure_arg args, kind: 'entity uuid'
        cloud = LMC::Cloud.instance
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud.auth_for_account root_account
        url_components = ['cloud-service-devices', 'accesscontrol', o['process-type'], o['entity-type'], args.first]
        cloud.delete url_components
      end
    end
  end
end
