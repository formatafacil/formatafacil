module Formatafacil
  ARTIGO_LATEX = "artigo.tex"
  ARTIGO_PDF = "artigo.pdf"
  
  class Compila
      def compila_artigo
        raise "Erro ao tentar compilar um arquivo que não existe: #{ARTIGO_LATEX}" unless File.exist?(ARTIGO_LATEX)
        system("/usr/bin/pdflatex -interaction=batchmode #{ARTIGO_LATEX}")
        system("/usr/bin/pdflatex -interaction=batchmode #{ARTIGO_LATEX}")
        raise "Erro durante a criação do PDF, provavelmente existe erro no arquivo #{ARTIGO_LATEX}" unless File.exist?(ARTIGO_PDF)        
      end
      
  end
end
