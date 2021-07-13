# frozen_string_literal: true
require 'chronic'

module LMCAdm #:nodoc:
  desc 'Retrieve montoring data'
  command :monitor do |monitor|
    monitor.flag :A, :account
    monitor.desc 'Get data for device'
    monitor.arg_name 'record datapoints', multiple: true
    monitor.command :device do |monitor_device|
      monitor_device.flag :D, :device
      monitor_device.flag :p, :period
      monitor_device.flag :s, :scalar, desc: 'scalar datapoint', multiple: true
      monitor_device.flag :r, :row, desc: 'row datapoint', multiple: true
      monitor_device.flag :c, :count, desc: 'fetch this many datapoints.', default_value: 10
      monitor_device.action do |_g, options, args|
        record_name = args.shift
        account = LMC::Account.get_by_uuid_or_name options[GLI::Command::PARENT][:account]
        device = account.devices.find { |d| d.name == options[:device] }
        record = device.record record_name

        options[:scalar].each do |datapoint|
          record_data = record.scalar datapoint, options[:count], options[:period]
          record_data.items[datapoint]['keys'].each do |key|
            puts "#{datapoint}-#{key}: #{record_data.items[datapoint]['values'].reverse.inspect}"
          end
        end

        options[:row].each do |datapoint|
          record_data = record.row datapoint, options[:count], options[:period]
          datapoint_items = record_data.items[datapoint]
          raise "Nothing returned for #{datapoint}" if datapoint_items.nil?
          table_cols = datapoint_items['keys']
          tables = datapoint_items['values']
          puts "Tables: #{tables.size}"
          tables.each do |table|
            puts "Table:"
            next if table.nil?
            rows = table.map do |row_source|
              row = {}
              table_cols.each_with_index do |name, index|
                row[name] = row_source[index]
              end
              row
            end
            tp rows
          end

        end
      end
    end

    monitor.desc 'Make raw monitoring requests'
    monitor.arg_name '<record> <name> <id>'
    monitor.command :raw do |raw|
      raw.flag :t, :type, default_value: 'scalar'
      raw.flag :g, :group, default_value: 'DEVICE'
      raw.flag :p, :period, default_value: 'MINUTE1'
      raw.desc 'Start time'
      raw.flag :start, default_value: 'one hour ago'
      raw.flag :end, default_value: 'now'
      raw.action do |_g, options, args|
        record = args.shift
        name = args.shift
        groupId = args.shift
        account = LMC::Account.get_by_uuid_or_name options[GLI::Command::PARENT][:account]
        account.cloud.auth_for_account account

        startTime = Chronic.parse(options[:start])
        puts "Start time: #{startTime}" if _g[:verbose]
        endTime = Chronic.parse(options[:end])
        puts "End time: #{endTime}" if _g[:verbose]

        # https://cloud.lancom.de/cloud-service-monitoring/accounts/399bc33a-7f53-4757-a6bd-cac3cbb6ebdd/records/wlan_info_json?type=scalar&name=stations&group=ACCOUNT&groupId=399bc33a-7f53-4757-a6bd-cac3cbb6ebdd&period=MINUTE1&start=1623417748&end=1623421348
        # https://cloud.lancom.de/cloud-service-monitoring/accounts/399bc33a-7f53-4757-a6bd-cac3cbb6ebdd/records/device_info?type=scalar&name=cloud_rtt&group=DEVICE&groupId=efec12e1-ac4d-459d-bb5d-a9b6c1410eb5&period=MINUTE1&start=1623419874&end=1623423474
        # https://cloud.lancom.de/cloud-service-monitoring/accounts/399bc33a-7f53-4757-a6bd-cac3cbb6ebdd/records/device_info?type=scalar&name=cloud_rtt&group=DEVICE&group_id=efec12e1-ac4d-459d-bb5d-a9b6c1410eb5&period=MINUTE1&start=1623419874&end=1623423474
        result = account.cloud.get ['cloud-service-monitoring', 'accounts', account.id, 'records', record], {
          type: options[:type],
          name: name,
          group: options[:group],
          groupId: groupId,
          period: options[:period],
          start: startTime.to_i,
          end: endTime.to_i,
        }
        base_timestamp = result.body.base
        delta = result.body.delta
        monitordata = result.body.items[name]
        puts result.body.inspect if _g[:debug]
        if options[:type] == 'scalar'
          table_data = monitordata.values.map.with_index { |row, row_index|
            {
              timestamp: DateTime.strptime((base_timestamp + delta * (monitordata.values.length - row_index)).to_s, '%s'),
              value: row,
            }
          }
          tp table_data
        elsif options[:type] == 'json'
          monitordata.to_h[:values].each.with_index { |row, row_index|
            puts DateTime.strptime((base_timestamp + delta * (monitordata.values.length - row_index)).to_s, '%s')
            puts JSON.pretty_generate row
          }
        elsif options[:type] == 'table'
          table_data = monitordata.values.map.with_index { |row, row_index|
            hash = { timestamp: DateTime.strptime((base_timestamp + delta * (monitordata.values.length - row_index)).to_s, '%s') }
            unless row.nil?
              row = row.first
              monitordata.keys.each_with_index { |k, column_index|
                unless row[column_index].nil?
                  hash[k] = row.first[column_index]
                end
              }
            end
            hash
          }
          tp table_data
        end
      end

    end

  end
end
