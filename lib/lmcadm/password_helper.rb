require 'io/console'

module LMCAdm
    module Helpers
        def self.read_pw(promptstring=nil)
          puts promptstring unless promptstring.nil?
          STDIN.noecho(&:gets).strip
        end
    end
end
