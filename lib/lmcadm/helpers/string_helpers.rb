module LMCAdm
  module Helpers
    def self.longest_in_collection(coll)
      max = coll.reduce(0) do |memo, str|
        memo > str.length ? memo : str.length

      end
      return max
    end
  end
end
