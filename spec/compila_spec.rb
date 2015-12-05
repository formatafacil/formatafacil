require 'spec_helper'
require 'formatafacil/compila'

describe Formatafacil::Compila do


  context 'Quando existe o arquivo artigo.tex', :i5 do
    before do
      allow(File).to receive('exist?').with("artigo.tex") { true }
    end
    context 'e arquivo foi compilado com sucesso' do
      before do
        allow(File).to receive('exist?').with("artigo.pdf") { true }
        expect(Kernel).to receive(:system).with('latexmk -pdf -time -silent artigo.tex')
      end
      it "invoca latexmk para criação do pdf" do
        subject.compila_artigo()
      end
      context "Quando otimizacão foi configurada", :i8 do
        before do
          subject.otimizador = double()
        end
        it "linealiza o pdf otimizando-o para web" do
          expect(subject.otimizador).to receive('otimiza_pdf')
          subject.compila_artigo()
        end
      end
      context "Quando otimização não foi configurada" do
        it "não tenta invoca otimizador nil" do
          expect{subject.compila_artigo()}.not_to raise_error
        end
      end
    end

    context "Se o pdf não foi gerado com sucesso" do
      before do
        expect(Kernel).to receive(:system)
        expect(File).to receive('exist?').with("artigo.pdf") { false }
      end
      it 'lança erro após compilação' do
        c = Formatafacil::Compila.new
        expect {c.compila_artigo}.to raise_error("Erro durante a criação do PDF, provavelmente existe erro no arquivo artigo.tex")
      end
    end
  end
  context 'Quando não existe o arquivo artigo.tex', :i5 do
    before do
      expect(File).to receive('exist?').with("artigo.tex") { false }
    end

    it 'emite erro antes de tentar compilar' do
      expect {subject.compila_artigo}.to raise_error("Erro ao tentar compilar um arquivo que não existe: artigo.tex")
    end
  end
end
