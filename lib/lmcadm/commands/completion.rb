# frozen_string_literal: true

module LMCAdm #:nodoc:
  desc 'Output shell commands to enable completion in bash'
  arg_name :shell
  command :completion do |completion|
    completion.action do |_o, _g, args|
      raise 'only bash supported at the moment' unless
          [nil, 'bash'].include? args.first
      puts <<'BASH'
#source this into your bash (via ~/.bashrc or other means)
complete -F _lmcadm_completions lmcadm
function _lmcadm_completions()
{
    COMPREPLY=(`lmcadm help -c "${COMP_WORDS[@]:1}"`)
}
BASH
    end
  end
end
