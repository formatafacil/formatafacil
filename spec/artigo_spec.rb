require 'spec_helper'
require 'formatafacil/artigo'

describe Formatafacil::Artigo do

  it 'possui um arquivo de entrada padrao' do
    artigo = Formatafacil::Artigo.new()
    expect(artigo.arquivo_entrada_padrao()).to eq("artigo.md")
  end

  it 'ler configurações de diversos lugares' do
    artigo = Formatafacil::Artigo.new()
    expect(artigo.arquivo_resumo).to eq("config/resumo.md")
    expect(artigo.arquivo_abstract).to eq("config/abstract.md")
  end
end
