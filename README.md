# Formatafacil


## Instalação

    $ gem install formatafacil

## Dependência

- `pandoc` para gerar os códigos latex
- `pdflatex` - para compilar texto em pdf
- `qpdf` se deseja compilar pdf otimizados para web
- [formatafacil-templates](http://github.com/formatafacil/formatafacil-templates) (instalado automaticamente através do gem)

## Usage

### Se instalou com gem

    formatafacil --help

### Se baixou diretamente do github

    bundle update
    bundle exec ./exe/formatafacil --help

### Em desenvolvimento

Muitas das funcionalidades ainda estão em desenvolvimento, **execute os testes**
para verificar o que está funcionando corretamente.

    bundle update
    bundle exec rspec

**TODO**: Write usage instructions here

# A command line app
As [David said], a cli command utility should:

## have a clear and concise purpose

Gerar arquivos PDFs de texto com formatações que o público brasileiro
necessita.

## be easy to use

Para gerar um artigo no [formato abnt](https://github.com/abntex/abntex2/blob/master/doc/latex/abntex2/examples/abntex2-modelo-artigo.tex):

    git clone git@github.com:formatafacil/artigo-abnt.git
    cd artigo-abnt
    formatafacil artigo

## be helpful

Com esta aplicação você poderá gerar artigos para o SBC, monografia, dissertação, tese, etc.

## play well with others (pending)

    formatafacil artigo -m artigo-abnt --log log.txt --input artigo.md --output meu-artigo-sbc.pdf

## delight casual users

Lista templates:

    formatafacil modelos

Cria um diretório e estrutura de um artigo no formato do sbc:

    formatafacil cria --template=artigo-abnt

## make configuration easy for advanced users

TODO

## install and distribute painlessly

    gem install formatafacil

## be well-tested and as bug free as possible

    bundle exec rspec

## be easy to maintain

TODO


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec formatafacil` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/formatafacil/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
