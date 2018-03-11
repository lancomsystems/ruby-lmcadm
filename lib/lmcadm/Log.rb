class LMCADMLogger
    def self.err
        @err ||= Logger.new(STDERR)
    end

    #def self.error
    #end
    
end
