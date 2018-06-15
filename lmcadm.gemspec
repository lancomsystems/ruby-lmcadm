
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lmcadm/version"

Gem::Specification.new do |spec|
  spec.name          = "lmcadm"
  spec.version       = LMCAdm::VERSION
  spec.authors       = ["erpel"]
  spec.email         = ["philipp@copythat.de"]

  spec.summary       = %q{lmcadm is a command line client for LMC}
  spec.homepage      = "http://copythat.de"
  spec.license       = "BSD-3-Clause"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry-nav", "0.2.4"

  spec.add_runtime_dependency 'lmc', '~> 0.3.0'
  spec.add_runtime_dependency 'gli', '~> 2.17'
  spec.add_runtime_dependency 'table_print', '~> 1.5'
  spec.add_runtime_dependency 'colorize'
end
