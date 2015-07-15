require 'spec_helper'
require 'formatafacil/compila'

describe Formatafacil::Compila do

  it 'compila artigo latex com pdflatex' do
    c = Formatafacil::Compila.new
    expect(File).to receive('exist?').with("artigo.tex") { true }
    expect(c).to receive(:system).with("/usr/bin/pdflatex -interaction=batchmode artigo.tex") { }
    expect(c).to receive(:system).with("/usr/bin/pdflatex -interaction=batchmode artigo.tex") { }
    c.compila_artigo()
  end

  it 'emite erro ao tentar compilar um arquivo latex que não existe' do
    c = Formatafacil::Compila.new
    
    expect(File).to receive('exist?').with("artigo.tex") { false }
    expect {c.compila_artigo}.to raise_error("Erro ao tentar compilar um arquivo que não existe: artigo.tex")
  end


  
end
