module LMCAdm
  command :principal do |principal|
    principal.desc "Create principal"
    principal.arg_name 'Principal name'
    principal.command :create do |pc|
      pc.flag :t, :type, :required => true
      pc.action do |global_options, options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        pw = Helpers::read_pw "Enter password for #{args.first}"
        principal = LMC::Principal.new({ 'name' => args.first, 'password' => pw, 'type' => options[:type] })
        puts principal.save.inspect
        begin
        rescue Exception => e
          puts e.inspect
          puts e.message.inspect
          puts e.response
          puts e.response.message
        end


      end
    end

    principal.desc "List principals"
    principal.command :list do |l|
      l.action do |global_options|
        c = LMC::Cloud.instance
        c.auth_for_account LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        principals = c.get ['cloud-service-auth', 'principals']
        tp principals.body, [{:id => {width: 36}}, :name, :type]
      end
    end

    principal.arg_name "Principal ID"
    principal.desc "Delete principal"
    principal.command :delete do |d|
      d.action do |global_options, options, args|
        c = LMC::Cloud.instance
        c.auth_for_account LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        c.delete ['cloud-service-auth', 'principals', args.first]

      end
    end
  end
end
