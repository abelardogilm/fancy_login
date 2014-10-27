$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fancy_login/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fancy_login"
  s.version     = FancyLogin::VERSION
  s.authors     = ["Abelardo Gil"]
  s.email       = ["abelardogilm@gmail.com"]
  s.homepage    = "https://github.com/abelardogilm/blah"
  s.summary     = "Balh"
  s.description = "Description of FancyLogin."

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency "jquery-rails"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "coffee-rails", "~> 3.2.2"
  s.add_runtime_dependency "sass-rails", "~> 3.2.3"
  s.add_runtime_dependency "compass", "0.12.6"
  s.add_runtime_dependency "compass-rails", "~> 1.0.3"
  s.add_runtime_dependency "compass-normalize"
  s.add_runtime_dependency "susy", "1.0.9"
end