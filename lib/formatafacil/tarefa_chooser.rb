# encoding: utf-8

require 'formatafacil/tarefa'

module Formatafacil

  class ArquivoConfiguracaoAusenteException < Exception
  end

  ##
  # Não encontrou um arquivo de texto com base nos modelos disponíveis.
  #
  class ArquivoDeTextoNaoEncontradoException < Exception
  end


  class TarefaChooser

    def escolhe_tarefa
      Formatafacil::TarefaModelos.new().modelos_disponiveis.each do |modelo|
        if existe_arquivo_de_texto?(markdown_file(modelo)) then
          return Formatafacil::ArtigoTarefa.new(modelo: modelo)
        else
          raise ArquivoDeTextoNaoEncontradoException
        end
      end
    end

    def markdown_file(file)
      "#{file}.md"
    end

    def existe_arquivo_de_texto?(arquivo)
      File.exist?(arquivo)
    end

  end

end
