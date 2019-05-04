require 'gli'
module LMCAdm
  include GLI::App
  extend self

  subcommand_option_handling :normal

  desc 'Work on accounts (invite users)'
  command :account do |c|
    c.desc 'Account type (DISTRIBUTION, ...)'
    c.flag :t, :account_type

    c.desc 'List accounts'
    c.command :list do |account_list|
      account_list.desc 'Show detailed info (long)'
      account_list.switch :l, :long
      account_list.action do |global_options, options, args|
        t = ProgressVisualizer.new "Cloud login"
        lmcen = LMC::Cloud.new(global_options[:cloud_host], global_options[:user], global_options[:password])
        t.done
        t = ProgressVisualizer.new "Getting accounts"
        accounts = lmcen.get_accounts_objects
        t.done
        if options[:account_type]
          accounts = accounts.select do |a|
            a["type"] == options[:account_type]
          end
        end
        accounts.sort {|a, b| a["name"] <=> b["name"]}.each do |account|
          puts account.inspect if global_options[:v]
          if options[:l]
            puts account["name"] + " (" + account["type"] + ") ID: " + account["id"]
          else
            puts account["name"] + " (" + account["type"] + ")"
          end
        end
        puts accounts.length.to_s + " Accounts found"
      end
    end

    c.desc 'Show account'
    c.arg_name 'UUID|Name'
    c.command :show do |account_show|

      account_show.action do |global_options, options, args|
        a = LMC::Account.get_by_uuid_or_name(args[0])
        puts a.inspect
        a.sites.each do |site|
          puts "#{site} - #{site.account}"
        end
      end
    end

    c.desc 'Show device config state summary for account'
    c.arg_name 'UUID|Name'
    c.command :configstates do |account_configstates|
      account_configstates.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name args[0]
        states = account.config_updatestates
        puts "Current: #{states.actual}, outdated: #{states.outdated}"
      end
    end

    c.desc 'Show account sites'
    c.arg_name 'UUID|Name', [:required]
    c.command :sites do |c|
      c.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name args[0]
        sites = account.sites
        sites.each do |site|
          puts "#{site} - Config current: #{site.configstates.actual}, outdated: #{site.configstates.outdated}"
        end
      end
    end

    c.arg_name "name"
    c.desc 'Create new accounts'
    c.command :create do |account_create|

      account_create.desc 'parent uuid|name'
      account_create.flag :p
      account_create.action do |global_options, options, args|
        parent = LMC::Account.get_by_uuid_or_name options[:p]
        t = ProgressVisualizer.new "Creating object"
        a = LMC::Account.new({ "name" => args.first,
                               "type" => options[GLI::Command::PARENT][:account_type],
                               "parent" => parent.id })
        t.done
        t = ProgressVisualizer.new "Saving #{a.name}"
        result = a.save
        t.done
        puts a.id
        puts result.inspect if global_options[:debug]


      end
    end


    c.arg_name 'UUID|Name'
    c.desc 'Delete account'
    c.command :delete do |account_del|
      account_del.desc 'Treat argument as pattern against account name'
      account_del.switch :e
      account_del.action do |global_options, options, args|
        t = ProgressVisualizer.new "Getting accounts"
        if options[:e]
          accounts = LMC::Cloud.instance.get_accounts_objects
          matched_accounts = accounts.select {|account| /#{args.first}/.match(account.name)}
        else
          matched_accounts = [LMC::Account.get_by_uuid_or_name(args.first)]
        end
        t.done
        puts 'Accounts to delete:'
        puts matched_accounts.map {|a| "#{a.id} - #{a.name}"}.join("\n")
        print('Type yes to confirm: ')
        exit unless STDIN.gets.chomp == 'yes'
        t = ProgressVisualizer.new "Deleting accounts"
        matched_accounts.each do |a|
          a.delete!
          t.dot
        end
        t.done
      end
    end

    c.arg_name 'UUID|Name'
    c.desc 'Show account logs'
    c.command :logs do |account_show|
      account_show.action do |global_options, options, args|
        t = ProgressVisualizer.new "Getting account"
        a = LMC::Account.get_by_uuid_or_name(args.first)
        t.done
        t = ProgressVisualizer.new "Getting account logs"
        logs = a.logs
        t.done
        logs.each do |line|
          puts "#{line['created']} #{line['message']}"
        end
      end
    end

    c.arg_name "new name"
    c.desc 'Rename account'
    c.command :rename do |account_rename|
      account_rename.desc 'Account uuid|name'
      account_rename.flag :A, :account
      account_rename.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        account.name = args.first
        account.save
      end
    end


    c.arg_name 'UUID|Name'
    c.desc 'List account members'
    c.command :memberlist do |memberlist|
      memberlist.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name args.first
        members = account.members
        tp members, [{ :id => { :width => 36 } }, :name, :type, :state, :invitationState, :principalState,
                     :authorities => { :display_method => lambda {|m|
                       m.authorities.map {|a|
                         a['name']
                       }.join(',')
                     }, :width => 128 }]
      end
    end

    c.arg_name '"Account name"|UUID', [:required]
    c.desc 'List authorities'
    c.command :authorities do |auth|
      auth.action do |_g, _o, args|
        account = LMC::Account.get_by_uuid_or_name args.first
        authorities = account.authorities
        max = Helpers::longest_in_collection(authorities.map {|a| a.name})
        tp authorities, [{ :id => { :width => 36 } }, { :name => { :width => max } }, :visibility, :type]
      end
    end

    c.desc 'Manage authorities'
    c.command :authority do |auth|
      auth.arg_name 'Authority name', [:required]
      auth.command :create do |create|
        create.desc '"Account name"|UUID'
        create.flag :A, :required => true
        create.action do |_global_options, options, _args|
          account = LMC::Account.get_by_uuid_or_name options[:A]
          auth = LMC::Authority.new({ 'name' => _args.first, 'visibility' => 'PRIVATE' }, account)
          puts auth.save
        end
      end
    end

    c.arg_name "email address", [:multiple]
    c.desc 'Invite members, requires an account type'
    c.command :invite do |account_invite|
      account_invite.flag :A, :account, :required => true
      account_invite.flag :r, :role, :required => true
      account_invite.flag :t, :type, :required => true
      account_invite.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        cloud = LMC::Cloud.instance
        chosen_authorities = account.authorities.select {|auth| auth.name == options[:role]}
        args.each do |email|
          cloud.invite_user_to_account email, account.id, options[:type], chosen_authorities
        end
      end
    end

    c.desc 'Leave account'
    c.arg_name "Account id"
    c.command :leave do |leave|
      leave.action do |_global_options, _options, args|
        account = LMC::Account.get_by_uuid(args[0])
        puts "Leave account \"#{account.name}\""
        puts account.remove_membership_self
      end
    end

    c.arg_name 'member name', [:required]
    c.desc 'Add Member'
    c.command :memberadd do |ma|
      ma.flag :A, :account, :required => true
      ma.action do |_global_options, options, args|
        target_account = LMC::Account.get_by_uuid_or_name options[:account]
        membership = LMC::Membership.new
        membership.name = args.first
        membership.type = "MEMBER"
        membership.state = "ACTIVE"
        membership.authorities = []
        puts membership.to_json
        c = LMC::Cloud.instance
        c.auth_for_account LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        c.post ['cloud-service-auth', 'accounts', target_account.id, 'members'], membership
      end
    end


    c.arg_name 'member name', [:required]
    c.desc 'Remove member from account'
    c.command :memberremove do |memberremove|
      memberremove.flag :A, :account, :required => true
      memberremove.action do |_global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name(options[:account])
        membership = account.find_member_by_name args.first
        puts "Leave account \"#{account.name}\""
        puts account.remove_membership membership.id
      end
    end

    c.arg_name 'member name', [:required]
    c.desc 'Update membership'
    c.command :memberupdate do |update|
      update.flag :A, :account, :required => true
      update.desc 'authority id'
      update.flag 'add-authority'
      update.action do |_global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name(options[:account])
        membership = account.find_member_by_name args.first
        puts membership
        if options['add-authority']
          # new_authority = account.authorities.find do |a|
          #   a.name == options['add-authority']
          # end
          puts membership.class
          puts membership.authorities.class
          authority_ids = membership.authorities.map do |a|
            a['id']
          end
          puts authority_ids
          authority_ids = authority_ids.concat [options['add-authority']]
          puts authority_ids
          # POST /accounts/{accountId}/members/{principalId}
          cloud = LMC::Cloud.instance
          cloud.auth_for_account account
          res = cloud.post ['cloud-service-auth', 'accounts', account.id, 'members', membership.id], { 'authorities' => authority_ids }
          puts res
        end
      end
    end


    c.desc 'List account children'
    c.arg_name 'UUID|Name'
    c.command :children do |children|
      children.flag :special
      children.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name args.first
        cloud = LMC::Cloud.instance

        def recurse_childen account, indent_level
          children = account.children
          children.each do |child|
            puts '  ' * indent_level + child.to_s
            begin
              recurse_childen child, indent_level + 1
            rescue RestClient::Forbidden => e
            end
          end
        end

        recurse_childen account, 0
      end
    end
  end
end
