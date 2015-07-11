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
    terafa = Formatafacil::ArtigoTarefa.new(:formato => 'sbc')
    expect(terafa.formato).to eq("sbc")
    expect(terafa.arquivo_resumo()).to eq("config/resumo.md")
    expect(terafa.arquivo_abstract()).to eq("config/abstract.md")
    expect(terafa.arquivo_texto()).to eq("artigo.md")
  end
  
  it 'gera um arquivo latex e compila pdf com o formato de artigo apropriado' do
    tarefa = Formatafacil::ArtigoTarefa.new(:formato => 'sbc')
    
    Dir.mktmpdir() { |dir|
      Dir.chdir(dir){
        criaExemploDeArtigo(tarefa)
        tarefa.executa
        
        expect(tarefa.artigo['resumo']).to eq("**meu-resumo**\n")
        expect(tarefa.artigo_latex['resumo']).to eq("\\textbf{meu-resumo}\n")
        
        expect(File.file?('artigo.yaml')).to eq(true)
        result = YAML.load_file(tarefa.arquivo_saida_yaml)
        expect(result['resumo']).to eq("\\textbf{meu-resumo}\n")
        
        expect(File.file?(tarefa.arquivo_latex)).to eq(true)
        expect(File.file?(tarefa.arquivo_pdf)).to eq(true)
      }
    }
  end



end
