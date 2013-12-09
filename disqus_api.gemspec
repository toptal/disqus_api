# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{disqus_api}
  s.version = "0.0.1"

  s.date = %q{2013-12-09}
  s.authors = ["Sergei Zinin"]
  s.email = %q{szinin@gmail.com}
  s.homepage = %q{http://github.com/einzige/disqus_api}

  s.licenses = ["MIT"]

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]

  s.description = %q{Provides clean Disqus API for your Ruby app with a nice interface.}
  s.summary = %q{Disqus API for Ruby}

  s.add_runtime_dependency 'activesupport', ">= 3.0.0"
  s.add_runtime_dependency 'faraday', ">= 0.8"
  s.add_runtime_dependency 'faraday_middleware', ">= 0.9"
  s.add_development_dependency 'bundler'
end

