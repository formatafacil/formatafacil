require 'formatafacil/tarefa'

module Formatafacil
  class TarefaChooser

    def escolhe_tarefa
      raise "Não foi possível localizar o arquivo de configuração: #{Formatafacil::Tarefa.arquivo_configuracao}" unless File.exist?(Formatafacil::Tarefa.arquivo_configuracao)
      Formatafacil::ArtigoTarefa.new
    end
    
  end
end
