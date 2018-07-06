module LMCAdm
  command :privatecloud do |pc|
    pc.arg_name 'Redirect URL'
    pc.desc 'Set redirect URL for account'
    pc.command :url do |url|
      url.flag :A, :account
      url.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        puts account
        LMC::Cloud.instance.auth_for_account account
        LMC::Cloud.instance.put ["cloud-service-devices", "accounts", account.id, "redirect" ], { "url" => args.first }
      end
    end

    pc.arg_name 'Account name|UUID'
    pc.desc 'Show privatecloud account infos'
    pc.command :show do |show|
      show.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name args.first
        LMC::Cloud.instance.auth_for_account account
        redirect = LMC::Cloud.instance.get ["cloud-service-devices", "accounts", account.id, "redirect" ]
        puts "Account: #{account}"
        puts "URL: " + redirect.body.url
      end
    end
  end
end
