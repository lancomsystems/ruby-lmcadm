module LMCAdm
  class LMCADMResultInterpreter
    def self.get_final_word(code)
      code_mappings = {
          200 => "Done",
          504 => "Timeout"
      }
      finalword = code_mappings[code]
      finalword ||= "UNKNOWN STATUS CODE"
    end

    def self.interpret(result)
      self.get_final_word(result.code)
    end

    def self.interpret_with_color(result)
      code = result.code
      finalword = self.get_final_word(code)
      if code == 200
        finalword = finalword.green
      elsif code <= 400 &&  code < 500
        finalword = finalword.yellow
      elsif code >= 500 && code < 600
        finalword = finalword.red
      end
      return finalword
    end
  end

end