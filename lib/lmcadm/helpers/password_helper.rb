# frozen_string_literal: true
require 'io/console'

module LMCAdm
  # This module includes helpers for shared functionality across the
  # application.
  module Helpers
    def self.read_pw(promptstring = '')
      print promptstring
      pw = STDIN.noecho(&:gets).strip
      print "\n"
      pw
    end
  end
end
