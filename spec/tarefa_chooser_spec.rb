require 'spec_helper'
require 'formatafacil/tarefa'
require 'formatafacil/artigo_tarefa'
require 'formatafacil/tarefa_chooser'
require 'tmpdir'
require 'yaml'
#require 'io'

describe Formatafacil::TarefaChooser do

  context 'Buscando uma tarefa para ser executada com base nos arquivos do diretório atual' do
    context 'Quando existe um arquivo com o mesmo nome de um modelo' do
      it 'Cria uma tarefa ArtigoTarefa com o modelo encontrado' do
        c = Formatafacil::TarefaChooser.new
        allow(c).to receive('existe_arquivo_de_texto?').with("artigo-abnt.md").and_return("true")
        tarefa = c.escolhe_tarefa
        expect(tarefa.modelo).to eq("artigo-abnt")
      end
    end

    context 'Quando NÃO existe arquivo de texto nomeado a partir de um modelo' do
      it 'Emite um erro indicando que não encontrou arquivo de texto com base nos modelos disponíveis' do
        c = Formatafacil::TarefaChooser.new
        expect { c.escolhe_tarefa }.to raise_error(Formatafacil::ArquivoDeTextoNaoEncontradoException)
      end
    end
  end

end
