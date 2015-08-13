# coding: utf-8
# rubocop:disable all
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib)
require 'hdfsutils/version'

Gem::Specification.new do |spec|
  spec.name          = 'hdfsutils'
  spec.version       = HdfsUtils::VERSION
  spec.authors       = ['David Chaiken']
  spec.email         = %w(chaiken@altiscale.com)
  spec.summary       = 'HDFS Utility Programs'
  spec.description   = 'Utility programs for access HDFS via WebHDFS'
  spec.homepage      = 'https://github.com/Altiscale/hdfsutils'
  spec.license       = 'Apache License 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'webmock', '~> 1.21'
  spec.add_development_dependency 'rubocop', '0.28.0'
  spec.add_runtime_dependency 'webhdfs', '~> 0.6.0.2'
  spec.add_runtime_dependency 'gssapi', '~> 1.2'
end

