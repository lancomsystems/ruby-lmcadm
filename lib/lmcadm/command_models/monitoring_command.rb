# first attempt at encapsulating a command into classes
#
# Getting monitoring data in general contains
# * Get the record by name from the device
# * scalars or rows depends on the record
# * currently no discovery for
# ** records
# ** datapoints in the record
# ** types of the datapoints
class MonitoringCommand
  attr_accessor :device, :record_name
  def execute
    record = device.record @record_name
    args.each do |datapoint|
      record_data = record.scalar datapoint, 10, options[:period]
      puts record_data.items.inspect
      record_data.items[datapoint]['keys'].each do |key|
        puts "#{datapoint}-#{key}: #{record_data.items[datapoint]['values'].inspect}"
      end
    end
  end
end

class MonitoringScalarCommand < MonitoringCommand

  def execute

  end
end