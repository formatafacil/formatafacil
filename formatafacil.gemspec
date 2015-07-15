# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formatafacil/version'

Gem::Specification.new do |spec|
  spec.name          = "formatafacil"
  spec.version       = Formatafacil::VERSION
  spec.authors       = ["Eduardo de Santana Medeiros Alexandre"]
  spec.email         = ["eduardo.ufpb@gmail.com"]
  
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end
  
  spec.summary       = %q{Compila arquivos escritos em Markdown para formatos.}
  spec.description   = %q{Com essa ferramenta você poderá compilar trabalhos de conclusão de curso (monografia, dissertação ou tese) ou artigos com as normas da ABNT ou outra específica }
  spec.homepage      = "https://github.com/edusantana/formatafacil"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_development_dependency "rspec"
  
  spec.add_dependency "gli"
  spec.add_dependency "formatafacil-templates"

end
