module LMCAdm
  command :maintenance do |maintenance|
    maintenance.arg_name 'Account UUID'
    maintenance.desc 'Resync license status in devices service for an account'
    maintenance.command :licenseresync do |resync|
      resync.action do |global_options, options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        result = cloud.post ['cloud-service-devices', 'maintenance', 'licenses', 'resync'], {'accountId' => args[0]}
      end
    end

    maintenance.arg_name 'Account UUID'
    maintenance.desc 'Enable scripting for an account'
    maintenance.command :scripting do |scr|
      scr.switch :enable
      scr.action do |global_options, options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        result = cloud.put ['cloud-service-config', 'configroot', 'accounts', args.first, 'scriptauthority'], options[:enable]
        raise "error - unexpected result" unless result.body == options[:enable]
      end
    end
  end
end
