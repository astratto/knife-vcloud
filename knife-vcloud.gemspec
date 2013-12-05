# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-vcloud/version'

Gem::Specification.new do |s|
  s.name = %q{knife-vcloud}
  s.version = KnifeVCloud::VERSION
  s.authors = ["Stefano Tortarolo"]
  s.email = ['stefano.tortarolo@gmail.com']
  s.summary = %q{A knife plugin for the VMWare vCloud API}
  s.homepage = %q{https://github.com/astratto/knife-vcloud}
  s.description = %q{A Knife plugin to create, list and manage vCloud servers}
  s.license     = 'Apache 2.0'

  s.add_dependency "chef", ">= 0.10.0"
  s.add_dependency "knife-windows", ">= 0"
  s.add_dependency "fog", "~> 1.18.0"
  s.add_dependency "winrm", "~> 1.1.3"
  s.require_path = 'lib'
  s.files = ["CHANGELOG.md","README.md", "LICENSE"] + Dir.glob("lib/**/*")
end
