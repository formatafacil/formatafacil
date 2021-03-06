require 'formatafacil/tarefa'

module Formatafacil
  ARTIGO_LATEX = "artigo.tex"
  ARTIGO_PDF = "artigo.pdf"

  class Compila < Tarefa
    attr_accessor 'otimizador'

    def compila_artigo


      raise "Erro ao tentar compilar um arquivo que não existe: #{ARTIGO_LATEX}" unless File.exist?(ARTIGO_LATEX)
      Kernel::system("latexmk -pdf -time -silent #{ARTIGO_LATEX}")
      raise "Erro durante a criação do PDF, provavelmente existe erro no arquivo #{ARTIGO_LATEX}" unless File.exist?(ARTIGO_PDF)

      @otimizador.otimiza_pdf unless @otimizador.nil?

      logger.info "Arquivo compilado com sucesso." unless logger.nil?

    end

  end
end
