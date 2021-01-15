# frozen_string_literal: true

module LMCAdm #:nodoc:
  desc 'Manipulate preferences'
  command :preferences do |preferences|
    preferences.desc 'Get last account data'
    preferences.arg_name 'accounts'
    preferences.command :lastaccounts do |la|
      la.action do |g, _o, args|
        cloud = LMC::Cloud.instance
        self_ui = cloud.preferences [:principals, :self, :ui]
        if args.empty?
          ids = self_ui.get 'lastAccountIds'
          accounts = ids.map do |id|
            LMC::Account.get id
          end
          accounts.each { |a|
            puts a.summary
          }
        else
          account_ids = args.map { |arg|
            LMC::Account.get_by_uuid_or_name(arg).id
          }
          puts account_ids
          puts self_ui.put 'lastAccountIds', account_ids
        end
      end
    end
  end
end

