require 'formatafacil/tarefa'

module Formatafacil
  class ArtigoTarefa < Tarefa
    attr_accessor 'arquivo_texto'
    attr_accessor 'arquivo_resumo'
    attr_accessor 'arquivo_abstract'
    attr_accessor 'arquivo_saida_yaml'
    attr_accessor 'formato'
    attr_accessor 'artigo' # conteúdo lidos os arquivos
    attr_accessor 'artigo_latex'
    attr_accessor 'arquivo_pdf'
    attr_accessor 'arquivo_latex'

    
    def initialize(h={})
      @arquivo_texto = 'artigo.md'
      @arquivo_resumo = 'config/resumo.md'
      @arquivo_abstract = 'config/abstract.md'
      @arquivo_saida_yaml = 'artigo.yaml'
      @arquivo_pdf = 'artigo.pdf'
      @arquivo_latex = 'artigo.tex'
      @artigo = {}
      @artigo_latex = {}
      h.each {|k,v| send("#{k}=",v)}
    end
    
    def executa
      ler_configuracao
      converte_configuracao_para_latex
      salva_configuracao_yaml_para_inclusao_em_pandoc
      executa_pandoc_salvando_latex
      executa_pdflatex
      
    end
    
    def ler_configuracao
      File.open(@arquivo_resumo, 'r') { |f| artigo['resumo'] = f.read }
      #File.open(@arquivo_abstract, 'r') { |f| artigo['abstract'] = f.read }
    end
    
    def converte_configuracao_para_latex
      @artigo_latex['resumo'] = `cat #{arquivo_resumo} | pandoc -f markdown -t latex`
    end
    

    def salva_configuracao_yaml_para_inclusao_em_pandoc
      File.open(@arquivo_saida_yaml, 'w'){ |file|
        file.write @artigo_latex.to_yaml
        file.write("---")
      }
    end
    
    def executa_pandoc_salvando_latex
      system "pandoc -s #{@arquivo_saida_yaml} #{@arquivo_texto} -f markdown -t latex -o #{@arquivo_latex}"
    end
    
    def executa_pdflatex
      system "pdflatex #{@arquivo_latex}"
      system "pdflatex #{@arquivo_latex}"
    end
       
  end
end
