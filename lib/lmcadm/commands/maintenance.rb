module LMCAdm
  command :maintenance do |license|
    license.arg_name 'Account UUID'
    license.desc 'Resync license status in devices service for an account'
    license.command :licenseresync do |resync|
      resync.action do |global_options, options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        result = cloud.post ['cloud-service-devices', 'maintenance', 'licenses', 'resync'], {'accountId' => args[0]}
      end
    end
  end
end
