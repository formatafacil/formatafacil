require 'spec_helper'
require 'formatafacil/tarefa'

describe Formatafacil::Tarefa do

  it 'possui um arquivo de configurações gerais' do
    expect(Formatafacil::Tarefa.arquivo_configuracao).to eq('config/1-configuracoes-gerais.yaml')
  end

  it 'possui um logger' do
    expect(Formatafacil::Tarefa.new.logger).to be nil
  end


end
