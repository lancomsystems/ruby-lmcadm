require 'gli'
module LMCAdm
  include GLI::App
  extend self
  subcommand_option_handling :normal
  desc 'Work on devices'

  command :device do |c|
    c.desc 'List devices'
    c.command :list do |device_list|
      device_list.desc 'Account UUID|Name'
      device_list.flag :A, :account, :required => true

      device_list.desc 'Include config information'
      device_list.switch :c, :config

      device_list.action do |global_options, options|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        t = ProgressVisualizer.new "Getting devices"
        devices = LMC::Device.get_for_account(account)
        t.done
        cols = [{:id => {width: 36}}, :name, :model, :serial, :heartbeatstate]
        if options[:config]
          cols << {"config_state.updateState" => {display_name: "config state"}}
          t = ProgressVisualizer.new "Getting config states"
          devices.each do |device|
            device.config_state
            t.dot
          end
          t.done
        end
        tp devices, cols
      end
    end

    c.arg_name "device uuid", [:multiple]
    c.desc 'Show device config'
    c.command :config do |device_config|
      device_config.desc 'Account UUID|Name'
      device_config.flag :A, :account

      device_config.desc 'Write to files'
      device_config.switch :w
      device_config.desc 'Prefix for files'
      device_config.default_value 'config'
      device_config.flag :p, :prefix

      device_config.desc "Filter OID"
      device_config.flag :filter_oid, "filter-oid"

      device_config.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        all_devices = LMC::Device.get_for_account(account)
        devices = all_devices.select do |device|
          args.include? device.id
        end
        devices.each do |device|
          full_config = device.get_config_for_account(account)
          result_config = full_config
          if options[:filter_oid]
            result_config = full_config["items"].select do |item|
              item == options[:filter_oid]
            end
          end
          puts "result_config class: " + result_config.class.to_s if global_options[:debug]
          puts "result_config class: " + result_config.body_object.class.to_s if global_options[:debug]
          pretty = JSON.pretty_generate(result_config)
          if options[:w]
            IO.write(options[:prefix] + "-" + device.name + '-' + device.id + ".json", pretty)
          else
            puts pretty
          end
        end

      end

    end

    c.arg_name "device uuid"
    c.desc 'Change device config'
    c.command :setconfig do |device_config|
      device_config.desc 'Account UUID|Name'
      device_config.flag :A, :account

      device_config.desc 'oid'
      device_config.flag :oid

      device_config.desc 'value'
      device_config.flag :value

      device_config.desc "json file with new settings\n same as output format but just keep items key on first level"
      device_config.flag :jsonfile

      device_config.action do |global_options, options, args|
        account = LMC::Account.get_by_uuid_or_name options[:account]
        t = ProgressVisualizer.new "Getting device..."
        all_devices = LMC::Device.get_for_account(account)
        devices = all_devices.select do |device|
          args.include? device.id
        end
        device = devices.first
        if !device.nil?
          t.finished "Done".green
        else
          t.finished "Failed".red
          raise "Device not found"
        end

        t = ProgressVisualizer.new "Getting current config..."
        config = device.get_config_for_account(account)
        t.finished " Done".green

        t = ProgressVisualizer.new "Applying changes..."
        if options[:jsonfile]
          jsoncontent = IO.read(options[:jsonfile])
          configchange = JSON.parse jsoncontent
          config.merge! configchange
        end
        if options[:oid] && options[:value]
          config['items'][options[:oid]] = options[:value]
        end
        config.delete "state" # should not send this back
        t.finished " Done".green

        puts JSON.pretty_generate(config) if global_options[:debug]
        t = ProgressVisualizer.new "Submitting new config..."
        result = device.set_config_for_account(config, account)
        if result.code == 200
          print " " + result["id"].to_s + "..."
        end
        t.finished " " + LMCADMResultInterpreter.interpret_with_color(result)
      end
    end

    c.arg_name '"search string"'
    c.desc 'Display device registration data'
    c.long_desc 'Search for device registration data. Currently supports serial numbers as search strings.'
    c.command :registration do |cmd|
      cmd.action do |_global_options, _options, args|
        root_account = LMC::Account.get LMC::Account::ROOT_ACCOUNT_UUID
        cloud = LMC::Cloud.instance
        cloud.auth_for_account root_account
        result = cloud.get ['cloud-service-devices', 'registrations'], {'updatePairing' => false, "status.serial" => args.first}
        result.body.each do |registration|

          registration.status.keys.each {|key|
            puts "#{key}: #{registration.status[key]}"
          }
          if registration.accountId
            #TODO Check if account info can be displayed via another endpoint
            #account = LMC::Account.get registration.accountId
            #puts account
            puts "accountID: #{registration.accountId}"
          end

        end
      end
    end
  end
end