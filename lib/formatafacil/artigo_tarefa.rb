require 'formatafacil/template'
require 'formatafacil/tarefa'
require 'open3'
require 'yaml'
require 'json'

module Formatafacil
  
  class ArtigoTarefa < Tarefa
    attr_accessor 'modelo'
    attr_accessor 'artigo' # conteúdo lidos os arquivos
    attr_accessor 'artigo_latex' # conteúdo convertido
    
    attr_accessor 'arquivo_texto'
    attr_accessor 'arquivo_resumo'
    attr_accessor 'arquivo_abstract'
    attr_accessor 'arquivo_ingles'
    attr_accessor 'arquivo_bibliografia'
    attr_accessor 'arquivo_saida_yaml'
    attr_accessor 'arquivo_saida_pdf'
    attr_accessor 'arquivo_saida_latex'

    def initialize(h={})
      @arquivo_texto = 'artigo.md'
      @arquivo_resumo = 'config/resumo.md'
      @arquivo_abstract = 'config/abstract.md'
      @arquivo_ingles = 'config/ingles.yaml'
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
      @artigo.merge!(YAML.load(ler_arquivo(Formatafacil::Tarefa.arquivo_configuracao)))
      converte_parametros_para_boolean
      
      @modelo = @artigo['modelo']
      
      @artigo['abstract'] = ler_arquivo(@arquivo_abstract)
      @artigo.merge!(ler_metadados_do_arquivo(@arquivo_abstract))
      @artigo['resumo'] = ler_arquivo(@arquivo_resumo)
      @artigo['bibliografia'] = ler_arquivo(@arquivo_bibliografia)
      
    end
    
    def ler_metadados_do_arquivo(arquivo)
      result = {}
      meta = JSON.parse(`pandoc -t json #{arquivo}`)[0]['unMeta']
      meta.each do |k,v|
        result[k]=converte_valor_da_arvore_pandoc(v)
      end
      result
    end
    
    def converte_valor_da_arvore_pandoc(node)
      #  {"boo_false"=>{"t"=>"MetaBool", "c"=>false}, "boo_true"=>{"t"=>"MetaBool", "c"=>true}, "nome_do_parametro"=>{"t"=>"MetaInlines", "c"=>[{"t"=>"Str", "c"=>"valor"}, {"t"=>"Space", "c"=>[]}, {"t"=>"Str", "c"=>"do"}, {"t"=>"Space", "c"=>[]}, {"t"=>"Str", "c"=>"parâmetro"}]}, "numero"=>{"t"=>"MetaString", "c"=>"15"}}
      result = nil

      case node['t']
      when "MetaString"
        result = node['c']
      when "MetaBool"
        result = node['c']
      when "MetaInlines"
        string = ""
        node['c'].each do |node|
          case node['t']
          when 'Str'
            string += node['c']
          when 'Space'
            string += " "
          end
        end
        if "sim".casecmp(string).zero?
          result = true
        elsif "não".casecmp(string).zero?
          result = false
        else
          result = string
        end
      else
        result = node
      end
      result
    end
    
    def ler_arquivo(arquivo)
      result = ""
      File.open(arquivo, 'r') { |f| result = f.read }
      result
    end
    
    def converte_parametros_para_boolean
      ['incluir_abstract'].each do |param|
        case @artigo[param]
        when true
          @artigo[param] = true
        when 'sim'
          @artigo[param] = true
        when 'Sim'
          @artigo[param] = true
        else
          @artigo[param] = false
        end
      end
    end
    
    def converte_configuracao_para_latex
      @artigo_latex.merge!(@artigo)
      
      ['resumo','abstract','bibliografia'].each {|key|
        Open3.popen3("pandoc --smart -f markdown -t latex") {|stdin, stdout, stderr, wait_thr|
          pid = wait_thr.pid # pid of the started process.
          stdin.write @artigo[key]
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

    
    def executa_pandoc_salvando_latex
      t = Formatafacil::Template.new()
      data_dir = t.directory
      
      system "pandoc --smart -s #{@arquivo_texto} #{@arquivo_saida_yaml}  --data-dir=#{data_dir} --template=#{modelo} -f markdown -t latex -o #{@arquivo_saida_latex}"
    end
    
    def executa_pdflatex
      #system "pdflatex #{@arquivo_saida_latex}"
      #system "pdflatex #{@arquivo_saida_latex}"
    end
       
  end
end
