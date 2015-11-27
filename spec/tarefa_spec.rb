require 'spec_helper'
require 'formatafacil/tarefa'

describe Formatafacil::Tarefa do

  

  it 'possui um logger' do
    expect(Formatafacil::Tarefa.new.logger).to be nil
  end


end
