# frozen_string_literal: true
module LMCAdm
  module Helpers
    # Verifies that args contains at least one object.
    # Raises RuntimeError with either the given message or an error explaining that kind is expected.
    #
    # @param [Object] args
    # @param [String (frozen)] kind optional
    # @param [Object] message optional
    def self.ensure_arg(args, kind: 'argument', message: nil)
      error = ""
      if args.length < 1
        error = "Argument missing: No #{kind} specified."
        error = message if message
      end
      raise error unless error.empty?
      return args
    end
  end
end

