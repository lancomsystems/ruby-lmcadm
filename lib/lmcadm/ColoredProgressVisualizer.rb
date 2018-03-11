require 'lmcadm/ProgressVisualizer.rb'
module LMCAdm
  class ColoredProgressVisualizer < ProgressVisualizer
      class << self
          attr_accessor :take_time
      end
      def initialize(taskstring)
          super "#{taskstring.bold}"
      end
      def success(endstring)
          finished(endstring.green)
      end
      def done()
          finished("done".green)
      end
  end
  
end