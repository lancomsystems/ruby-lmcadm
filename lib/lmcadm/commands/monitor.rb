# frozen_string_literal: true

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
        device = account.devices.find {|d| d.name == options[:device]}
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
  end
end
