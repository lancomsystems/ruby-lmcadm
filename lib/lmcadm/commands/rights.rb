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
      assign.flag :A, :account
      assign.flag :authority
      assign.flag :service
      assign.action do |_g, o, a |
        #POST /accounts/{accountId}/authorities/{authorityId}/rights
        account = LMC::Account.get_by_uuid_or_name o[:A]
        c = LMC::Cloud.instance
        c.auth_for_account account
        service_name = Helpers.complete_service_name o[:service]
        c.post [service_name, "accounts", account.id, 'authorities', o[:authority], 'rights' ], a

      end
    end
    rights.arg_name 'servicename account'
    rights.desc 'example: lmcadm rights authorities messaging myproject'
    rights.command :authorities do |authorities|
      authorities.action do |_g, _o, a |
        account = LMC::Account.get_by_uuid_or_name a[1]
        account.cloud.auth_for_account account
        authorities = account.cloud.get [Helpers.complete_service_name(a[0]), 'accounts', account.id, 'authorities']
        tp authorities.body, [:name , :visibility, :type, :id]
      end
    end

    rights.arg_name '<servicename> <account> <authority_id>'
    rights.desc 'example: lmcadm rights show service-messaging myproject 5c244078-c937-4ff9-bb33-351f5253fe53'
    rights.command :show do |show|
      show.action do |_g, _o, a|
        account = LMC::Account.get_by_uuid_or_name a[1]
        account.cloud.auth_for_account account
        service_name = Helpers.complete_service_name a[0]
        authority = account.cloud.get([service_name, 'accounts', account.id, 'authorities', a[2]]).body
        puts authority.to_h.to_s
        rights = account.cloud.get([service_name, 'accounts', account.id, 'authorities', a[2], 'rights']).body
        puts rights
      end
    end
  end
end
