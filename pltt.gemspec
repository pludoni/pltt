lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pltt/version"

Gem::Specification.new do |spec|
  spec.name          = "pltt"
  spec.version       = Pltt::VERSION
  spec.authors       = ["Stefan Wienert"]
  spec.email         = ["info@stefanwienert.de"]

  spec.summary       = %{Pltt is a gtt gitlab-time-tracker compatible CLI client for time tracking issues from command line}
  spec.description   = %{Pltt is a Gitlab Time Tracker client for the command line. It mimics the interface of https://github.com/kriskbx/gitlab-time-tracker and is compatible to the config and frame database. Thus, it works as a drop-in-replacement.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'gitlab', '~> 4.4.0'
  spec.add_dependency 'hashids'
  spec.add_dependency 'oj'
  spec.add_dependency 'terminal-table', '>= 1.8.0'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-prompt'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
end
