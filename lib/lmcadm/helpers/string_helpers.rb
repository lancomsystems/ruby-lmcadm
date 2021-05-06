module LMCAdm
  module Helpers
    def self.longest_in_collection(coll)
      max = coll.reduce(0) do |memo, str|
        memo > str.length ? memo : str.length

      end
      return max
    end

    def self.complete_service_name(name)
      if name.start_with? 'cloud-service-'
        return name
      end
      if name.start_with? 'service-'
        return 'cloud-' + name
      end
      return'cloud-service-' + name
    end
  end
end
