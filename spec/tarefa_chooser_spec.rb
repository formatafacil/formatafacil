require 'spec_helper'
require 'formatafacil/tarefa'
require 'formatafacil/artigo_tarefa'
require 'formatafacil/tarefa_chooser'
require 'tmpdir'
require 'yaml'
#require 'io'

describe Formatafacil::TarefaChooser do

  it 'escolhe a tarefa com base no arquivo de configuração' do
    c = Formatafacil::TarefaChooser.new
    Dir.mktmpdir() { |dir| Dir.chdir(dir){
      cria_arquivo_configuracao({'tipo' => 'artigo', 'modelo'=>'abnt'})
      expect(File.exist?(Formatafacil::Tarefa.arquivo_configuracao)).to eq(true)
      
      t = c.escolhe_tarefa
      expect(t).to be_an_instance_of(Formatafacil::ArtigoTarefa)
    }}
  end


  it 'dá error se não existir o arquivo de configurações gerais' do
    c = Formatafacil::TarefaChooser.new
    expect { c.escolhe_tarefa }.to raise_error("Não foi possível localizar o arquivo de configuração: #{Formatafacil::Tarefa.arquivo_configuracao}")
  end


end
