# encoding: utf-8

require 'formatafacil/tarefa'

module Formatafacil

  class TarefaModelos < Tarefa

    def executa
      modelos_disponiveis.each {|n| puts n}
    end

    def modelos_disponiveis
      Formatafacil::Template.new().list_names()
    end

  end

end
