module LMCAdm
  class ProgressVisualizer
    class << self
      attr_accessor :take_time
    end

    def initialize(taskstring)
      print "#{taskstring} "
      @itemized = false
      @start = Time.now if ProgressVisualizer.take_time
    end

    def perform
      print "#{taskstring} "
      @itemized = false
      @start = Time.now if ProgressVisualizer.take_time
    end

    def finished(endstring)
      if @itemized
        endstring = ' ' + endstring
      end
      if ProgressVisualizer.take_time
        elapsed = (Time.now - @start) * 1000
        endstring = endstring + " (" + elapsed.to_s + "ms)"
      end
      puts endstring
    end

    def success(endstring)
      finished(endstring)
    end

    def done()
      finished("done")
    end

    def itemize(str)
      @itemized = true
      print str
    end

    def X()
      itemize "X"
    end

    def dot()
      itemize "."
    end
  end

end