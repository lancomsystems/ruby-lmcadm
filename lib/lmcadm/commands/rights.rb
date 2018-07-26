module LMCAdm
  command :rights do |rights|
    rights.command :list do |list|
      list.action do |options, global_options, args|
        c = LMC::Cloud.instance
        LMC::SERVICELIST.each do |service|
          puts service
          begin
            puts "#{c.get([service, "rights", "public"]).body}\n\n"
          rescue RestClient::Exception =>e
            puts e.response
            end
        end
      end
    end
    rights.arg_name "rights"
    rights.command :assign do |assign|
      assign.flag :A
      assign.flag :authority
      assign.flag :service
      assign.action do |_g, o, a |
        #POST /accounts/{accountId}/authorities/{authorityId}/rights
        account = LMC::Account.get_by_uuid_or_name o[:A]
        c = LMC::Cloud.instance
        c.auth_for_account account
        c.post [o[:service], "accounts", account.id, 'authorities', o[:authority], 'rights' ], a

      end
    end
  end
end