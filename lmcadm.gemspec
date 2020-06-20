
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lmcadm/version"

Gem::Specification.new do |spec|
  spec.name          = "lmcadm"
  spec.version       = LMCAdm::VERSION
  spec.authors       = ["erpel"]
  spec.email         = ["philipp@copythat.de"]
  spec.required_ruby_version = '~> 2.0'
  spec.summary       = %q{lmcadm is a command line client for LMC}
  spec.license       = "BSD-3-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry-nav", "0.2.4"

  spec.add_runtime_dependency 'lmc', '~> 0.12.0'
  spec.add_runtime_dependency 'gli', '~> 2.17'
  spec.add_runtime_dependency 'table_print', '~> 1.5'
  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'websocket-eventmachine-client', '~> 1.3.0'
end
