# frozen_string_literal: true
module LMCAdm
  module Helpers
    def self.find_by_id_or_name(list, search)
      found = []
      found += list.select do |item|
        item.id == search
      end
      found += list.select do |item|
        item.name == search
      end
      puts "More than one item found for: #{search}" if found.length > 1
      raise "Not found: #{search}" if found.length < 1
      return found.first
    end
  end
end

