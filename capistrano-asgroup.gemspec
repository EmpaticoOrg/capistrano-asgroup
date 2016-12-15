# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'capistrano/version'

Gem::Specification.new do |s|
  s.name        = 'capistrano-asgroup'
  s.version     = Capistrano::Asgroup::VERSION
  s.authors     = ['Piotr Jasiulewicz', 'Thomas Verbiscer', 'James Turnbull']
  s.homepage    = 'https://github.com/EmpaticoOrg/capistrano-asgroup'
  s.license     = 'MIT'
  s.email       = 'jturnbull@emaptico.org'
  s.summary     = 'A Capistrano3 plugin aimed at easing the pain of deploying to AWS Auto Scale instances.'
  s.description = ''

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'capistrano', '>=3.4.0'
  s.add_dependency 'aws-sdk', '>=2.0'
end
