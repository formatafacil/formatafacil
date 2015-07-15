module Formatafacil
  class Compila

      def compila_artigo
        arquivo = "artigo.tex"
        raise "Erro ao tentar compilar um arquivo que não existe: artigo.tex" unless File.exist?(arquivo)
        system("/usr/bin/pdflatex -interaction=batchmode artigo.tex")
        system("/usr/bin/pdflatex -interaction=batchmode artigo.tex")
      end

  end
end
