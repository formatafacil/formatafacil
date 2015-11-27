require 'spec_helper'
require 'formatafacil/tarefa'
require 'formatafacil/tarefa_modelos'
require 'tmpdir'
require 'yaml'
#require 'io'

describe Formatafacil::TarefaModelos do

  it 'consulta os modelos disponíveis' do
    c = Formatafacil::TarefaModelos.new
    expect(c.modelos_disponiveis()).to include("artigo-abnt")
  end

  it 'imprime os modelos disponíveis' do

    expect { c = Formatafacil::TarefaModelos.new().executa }.to output("artigo-abnt\n").to_stdout

  end


end
