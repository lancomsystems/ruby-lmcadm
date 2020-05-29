# frozen_string_literal: true
module LMCAdm
  module Helpers
    def self.find_device(devices, name: '', id: '')
      found = devices.select do |device|
        (id == device.id) || (name == device.name)
      end
      raise "More than one device found for: #{name} #{id}" if found.length > 1
      raise "Device not found: #{name} #{id}" if found.length < 1
      return found.first
    end
  end
end

