require 'spec_helper'
require 'formatafacil/artigo_tarefa'
require 'tmpdir'
require 'yaml'
#require 'io'

describe Formatafacil::ArtigoTarefa do

  it 'possui configuração padrão para leitura dos arquivos' do
    terafa = Formatafacil::ArtigoTarefa.new
    expect(terafa.arquivo_resumo()).to eq("config/resumo.md")
    expect(terafa.arquivo_abstract()).to eq("config/abstract.md")
    expect(terafa.arquivo_texto()).to eq("artigo.md")
  end

  it 'possui um formato para geração' do
    terafa = Formatafacil::ArtigoTarefa.new(:modelo => 'sbc')
    expect(terafa.modelo).to eq("sbc")
    expect(terafa.arquivo_resumo()).to eq("config/resumo.md")
    expect(terafa.arquivo_abstract()).to eq("config/abstract.md")
    expect(terafa.arquivo_texto()).to eq("artigo.md")
  end
  
  it 'gera um arquivo latex e compila pdf com o formato de artigo apropriado' do
    tarefa = Formatafacil::ArtigoTarefa.new(:modelo => 'sbc')
    
    Dir.mktmpdir() { |dir|
      Dir.chdir(dir){
        criaExemploDeArtigo(tarefa)
        #tarefa.executa
        
        #expect(tarefa.artigo['resumo']).to eq("**meu-resumo**\n")
        #expect(tarefa.artigo_latex['resumo']).to eq("\\textbf{meu-resumo}\n")
        
        #expect(File.file?('artigo.yaml')).to eq(true)
        #result = YAML.load_file(tarefa.arquivo_saida_yaml)
        #expect(result['resumo']).to eq("\\textbf{meu-resumo}\n")
        
        #expect(File.file?(tarefa.arquivo_latex)).to eq(true)
        #expect(File.file?(tarefa.arquivo_pdf)).to eq(true)
      }
    }
  end

  it 'gera um artigo latex com o template apropriado' do
    tarefa = Formatafacil::ArtigoTarefa.new(:modelo => 'abnt')
    
    palavras_chave = "um. dois. três."
    dentro_do_resumo = "Segue texto que deve vir dentro do resumo."
    resumo = <<RESUMO
Este é o resumo do meu artigo, ele pode conter
entre 150 a 500 palavras ou **words**.
#{dentro_do_resumo}

**Palavras-chave**: #{palavras_chave}
RESUMO

    keywords = 'latex. abntex. formatafacil.'
    abstract = <<ABSTRACT
According to ABNT NBR 6022:2003, an abstract in foreign language is a back
matter mandatory element.

**Keywords**: #{keywords}

ABSTRACT

    ingles = {"titulo_em_ingles"=>'English title', 'incluir_abstract'=>'sim'}
    
    titulo_da_obra = "Título da Obra"
    autores = "Nome-do-autor"
    data = "18/07/2015"
    titulo_da_secao = "Primeira seção"
    primeiro_paragrafo = "Texto do primeiro parágrafo!"
    citacao = "Minha citação aqui."
    texto = <<TEXTO
\% #{titulo_da_obra}
\% #{autores}
\% #{data}

# #{titulo_da_secao}

#{primeiro_paragrafo}

> #{citacao}

TEXTO

    bibliografia = <<BIBLIOGRAFIA
# Referências

GOMES, L. G. F. F. *Novela e sociedade no Brasil*. Niterói: EdUFF,
1998. 137 p., 21 cm. (Coleção Antropologia e Ciência Política, 15).
Bibliografia: p. 131-132. ISBN 85-228-0268-8.

BIBLIOGRAFIA

    Dir.mktmpdir() { |dir| Dir.chdir(dir){
      Dir.mkdir('config')
      tarefa.cria_arquivo_texto(texto)
      expect(File.file?(tarefa.arquivo_texto)).to eq(true)
      tarefa.cria_arquivo_resumo(resumo)
      expect(File.file?(tarefa.arquivo_resumo)).to eq(true)
      tarefa.cria_arquivo_abstract(abstract)
      expect(File.file?(tarefa.arquivo_abstract)).to eq(true)
      tarefa.cria_arquivo_bibliografia(bibliografia)
      expect(File.file?(tarefa.arquivo_bibliografia)).to eq(true)
      tarefa.cria_arquivo_ingles(ingles)
      expect(File.file?(tarefa.arquivo_ingles)).to eq(true)
      
      tarefa.executa
      
      expect(File.file?('artigo.yaml')).to eq(true)
      result = YAML.load_file(tarefa.arquivo_saida_yaml)
      expect(result['resumo'].include?(dentro_do_resumo)).to eq(true)
      
      expect(tarefa.artigo_latex['resumo'].include?(dentro_do_resumo)).to eq(true)
      
      expect(File.file?(tarefa.arquivo_saida_latex)).to eq(true)
      conteudo = ""
      File.open(tarefa.arquivo_saida_latex, 'r') { |f| conteudo = f.read }

      expect(conteudo.include?('abnTeX2')).to eq(true)
      expect(conteudo.include?(titulo_da_obra)).to eq(true)
      expect(conteudo.include?(autores)).to eq(true)
      
      expect(conteudo.include?(data)).to eq(true)
      expect(conteudo.include?(dentro_do_resumo)).to eq(true)
      expect(conteudo.include?("\\textbf{words}")).to eq(true)
      
      expect(conteudo.include?("\\titulo{#{titulo_da_obra}}")).to eq(true)
      expect(conteudo.include?(titulo_da_secao)).to eq(true)
      expect(conteudo.include?("\\section{#{titulo_da_secao}}")).to eq(true)
      expect(conteudo.include?(primeiro_paragrafo)).to eq(true)
      expect(conteudo.include?("\\begin{quote}\n#{citacao}\n\\end{quote}")).to eq(true)
      
      expect(conteudo.include?("GOMES")).to eq(true)
      
      usar_ingles = true
      expect(conteudo.include?(ingles["titulo_em_ingles"])).to eq(usar_ingles)
      expect(conteudo.include?(keywords)).to eq(usar_ingles)
      #expect(conteudo).to eq("")
      
    }}
  end





end
