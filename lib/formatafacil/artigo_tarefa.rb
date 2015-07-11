require 'formatafacil/template'
require 'formatafacil/tarefa'
require 'open3'
require 'yaml'

module Formatafacil
  
  class ArtigoTarefa < Tarefa
    attr_accessor 'formato'
    attr_accessor 'artigo' # conteúdo lidos os arquivos
    attr_accessor 'artigo_latex' # conteúdo convertido
    
    attr_accessor 'arquivo_texto'
    attr_accessor 'arquivo_resumo'
    attr_accessor 'arquivo_abstract'
    attr_accessor 'arquivo_bibliografia'
    attr_accessor 'arquivo_saida_yaml'
    attr_accessor 'arquivo_saida_pdf'
    attr_accessor 'arquivo_saida_latex'

    def initialize(h={})
      @arquivo_texto = 'artigo.md'
      @arquivo_resumo = 'config/resumo.md'
      @arquivo_abstract = 'config/abstract.md'
      @arquivo_bibliografia ='bibliografia.md'
      @arquivo_saida_yaml = 'artigo.yaml'
      @arquivo_saida_pdf = 'artigo.pdf'
      @arquivo_saida_latex = 'artigo.tex'
      @artigo = {}
      @artigo_latex = {}
      h.each {|k,v| send("#{k}=",v)}
    end
    
    def executa
      ler_configuracao
      executa_com_configuracao
    end
    
    def executa_com_configuracao
      converte_configuracao_para_latex
      salva_configuracao_yaml_para_inclusao_em_pandoc
      executa_pandoc_salvando_latex
      executa_pdflatex
    end
    
    # Ler as configurações dos arquivos:
    #
    # @arquivo_resumo
    def ler_configuracao
      File.open(@arquivo_resumo, 'r') { |f| artigo['resumo'] = f.read }
      File.open(@arquivo_bibliografia, 'r') { |f| artigo['bibliografia'] = f.read }
      #File.open(@arquivo_abstract, 'r') { |f| artigo['abstract'] = f.read }
    end
    
    def converte_configuracao_para_latex
      
      ['resumo','texto', 'bibliografia'].each {|key|
        Open3.popen3("pandoc -f markdown -t latex") {|stdin, stdout, stderr, wait_thr|
          pid = wait_thr.pid # pid of the started process.
          stdin.write artigo[key]
          stdin.close
          @artigo_latex[key] = stdout.read
        }
      }
    end
    
    

    def salva_configuracao_yaml_para_inclusao_em_pandoc
      File.open(@arquivo_saida_yaml, 'w'){ |file|
        file.write @artigo_latex.to_yaml
        file.write("---")
      }
    end

    def cria_arquivo(arquivo, string)
      File.open(arquivo, 'w'){ |file| file.write string }
    end

    def cria_arquivo_texto(string)
      cria_arquivo(@arquivo_texto, string)
    end
    def cria_arquivo_resumo(string)
      cria_arquivo(@arquivo_resumo, string)
    end
    def cria_arquivo_bibliografia(string)
      cria_arquivo(@arquivo_bibliografia, string)
    end
    
    def executa_pandoc_salvando_latex
      t = Formatafacil::Template.new()
      data_dir = t.directory
      
      system "pandoc -s #{@arquivo_texto} #{@arquivo_saida_yaml}  --data-dir=#{data_dir} --template=artigo-#{formato} -f markdown -t latex -o #{@arquivo_saida_latex}"
    end
    
    def executa_pdflatex
      #system "pdflatex #{@arquivo_saida_latex}"
      #system "pdflatex #{@arquivo_saida_latex}"
    end
       
  end
end
