$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "lmcadm"
require 'lmc'
require "minitest/autorun"

module Fixtures
  def self.device(data)
    data = {'status' => {}, 'account' => account}.merge(data)
    LMC::Device.new data
  end

  def self.account()
    LMC::Account.new true, {}
  end
end