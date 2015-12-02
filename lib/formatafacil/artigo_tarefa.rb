# encoding: utf-8

require 'formatafacil/template'
require 'formatafacil/tarefa'
require 'open3'
require 'yaml'
require 'json'

module Formatafacil

  class ArquivoDeArtigoNaoEncontradoException < StandardError
  end
  class ArquivoDeResumoNaoEncontradoError < StandardError
  end

  class ArtigoTarefa < Tarefa
    attr_accessor 'modelo'
    attr_accessor 'metadados'
    attr_accessor 'bibliografia'
    attr_accessor 'texto'
    attr_accessor 'resumo'
    attr_accessor 'abstract'

    attr_accessor 'artigo' # conteúdo lidos os arquivos
    attr_accessor 'artigo_latex' # conteúdo convertido
    # conteúdo convertido

    attr_accessor 'arquivo_texto'
    attr_accessor 'arquivo_resumo'
    attr_accessor 'arquivo_abstract'
    attr_accessor 'arquivo_bibliografia'
    # Arquivo padrão de leitura dos metadados: metadados.yaml
    attr_accessor 'arquivo_metadados'
    attr_accessor 'arquivo_saida_yaml'
    attr_accessor 'arquivo_saida_pdf'
    attr_accessor 'arquivo_saida_latex'

    ##
    # Um parâmetro obrigatório é o modelo do artigo
    #
    def initialize(h={})
      @arquivo_resumo = 'resumo.md'
      @arquivo_abstract = 'abstract.md'
      @arquivo_bibliografia ='bibliografia.md'
      @arquivo_metadados = 'metadados.yaml'
      @arquivo_saida_yaml = 'artigo.yaml'
      @arquivo_saida_pdf = 'artigo.pdf'
      @arquivo_saida_latex = 'artigo.tex'
      @artigo = {}
      @artigo_latex = {}
      @metadados = {}
      h.each {|k,v| send("#{k}=",v)}
      @arquivo_texto = "#{modelo}.md"
    end

    def executa
      verifica_conteudos
      unifica_metadados
      escreve_artigo_latex
      #ler_configuracao
      #executa_com_configuracao
    end

    ##
    # Ler as configurações dos arquivos:
    #
    # @arquivo_resumo
    def ler_configuracao
      #@artigo.merge!(YAML.load(ler_arquivo(Formatafacil::Tarefa.arquivo_configuracao)))
      #converte_parametros_para_boolean

      #@modelo = @artigo['modelo']
      if File.exist?(@arquivo_abstract) then
        @artigo['abstract'] = ler_arquivo(@arquivo_abstract)
        @artigo.merge!(ler_metadados_do_arquivo(@arquivo_abstract))
      end
      if File.exist?(@arquivo_resumo) then
        @artigo['resumo'] = ler_arquivo(@arquivo_resumo)
      end
      @artigo['bibliografia'] = ler_arquivo(@arquivo_bibliografia) if File.exist?(@arquivo_bibliografia)

      #unifica_metadados

    end

    def ler_metadados_do_arquivo(arquivo)
      result = {}
      meta = JSON.parse(`pandoc -t json #{arquivo}`)[0]['unMeta']
      meta.each do |k,v|
        result[k]=converte_valor_da_arvore_pandoc(v)
      end
      result
    end

    ##
    # Converte os arquivos secundários para latex, e salva junto com os
    # blocos yaml no hash +metadados+.
    #
    def unifica_metadados
      #salva_resumo_em_metadados
      #salva_blocos_de_metadados
      @metadados['resumo'] = converte_conteudo_para_latex(@resumo)
      @metadados['abstract'] = converte_conteudo_para_latex(@abstract)
      @metadados['bibliografia'] = converte_conteudo_para_latex(@bibliografia)
      @metadados.merge!(extrai_blocos_yaml(@abstract))
    end

    def modelos
      Formatafacil::Template.new().artigo_modelos
    end

    def exporta_conteudo_markdown
      "#{@texto}\n#{@metadados.to_yaml}---\n"
    end

    def converte_artigo_para_latex
      result = ""
      t = Formatafacil::Template.new()
      Open3.popen3("pandoc --smart --standalone --no-wrap --data-dir=#{t.directory} --template=#{modelo} -f markdown -t latex") {|stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
        stdin.write exporta_conteudo_markdown
        stdin.close
        result = stdout.read
      }
      result
    end

    def converte_conteudo_para_latex(conteudo)
      result = ""
      Open3.popen3("pandoc --smart -f markdown -t latex") {|stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
        stdin.write conteudo
        stdin.close
        result = stdout.read
      }
      result.strip
    end

    private

    def escreve_artigo_latex
      #File.open('artigo.tex', 'w'){|f| f.write('Primeira seção aqui')}
      #File.open(@arquivo_saida_latex, 'w') {|f| f.write (converte_artigo_para_latex)}
      File.open('artigo.tex', 'w') {|f| f.write (converte_artigo_para_latex)}
    end

    # Se não houver conteúdos, tentar ler dos arquivos correspondentes
    def verifica_conteudos
      identifica_modelo
      File.open(@arquivo_texto, 'r') {|f| @texto = f.read} if @texto.nil?
      File.open(@arquivo_resumo, 'r') {|f|
        begin
          @resumo = f.read
        rescue Errno::ENOENT
          raise Formatafacil::ArquivoDeResumoNaoEncontradoError, "Não possível encontrar o arquivo de resumo: [\"resumo.md\"]. Crie o arquivo com o nome apropriado e tente novamente."
        end
        } if @resumo.nil?
      File.open(@arquivo_abstract, 'r') {|f| @abstract = f.read} if @abstract.nil?
      File.open(@arquivo_bibliografia, 'r') {|f| @bibliografia = f.read} if @bibliografia.nil?
      File.open(@arquivo_metadados, 'r') {|f| @metadados = YAML.load(f.read)} if @metadados.empty?
    end

    def identifica_modelo
      if (@modelo.nil?) then
        t = Formatafacil::Template.new()
        @modelo = t.procura_modelo_de_artigo
        if (@modelo.nil?) then
          #raise "Modelo não encontrado. Modelos disponíveis: #{t.list_names}"
          nomes_dos_arquivos = t.list_names.map { |n| "#{n}.md" }
          raise ArquivoDeArtigoNaoEncontradoException, "Não possível encontrar um arquivo de artigo: #{nomes_dos_arquivos}. Crie o arquivo com o nome do modelo apropriado e tente novamente."
        end
      end
      @arquivo_texto = "#{@modelo}.md"
    end

    ##
    # Returna um hash contendo os conteúdos lidos dos blocos yaml.
    #
    def extrai_blocos_yaml(conteudo)
      result = {}
      Open3.popen3("pandoc -t json") {|stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
        stdin.write conteudo
        stdin.close
        meta = JSON.parse(stdout.read)[0]['unMeta']
        meta.each do |k,v|
          result[k]=converte_valor_da_arvore_pandoc(v)
        end
      }
      result
    end


    def salva_blocos_de_metadados
      [@resumo].each {|texto|
        Open3.popen3("pandoc -t json -f markdown") {|stdin, stdout, stderr, wait_thr|
          pid = wait_thr.pid # pid of the started process.
          stdin.write texto

          stdin.close

          conteudo = stdout.read
          meta = JSON.parse(conteudo)[0]['unMeta']
          puts "\nMeta: #{meta}"
          puts "\nmetadados: #{@metadados}"
          meta.each do |k,v|
            #result[k]=converte_valor_da_arvore_pandoc(v)
            #@metadados[k] = converte_valor_da_arvore_pandoc(v)
            @metadados[k] = v
          end
        }
      }
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

    ##
    # Converte os arquivos de texto markdown para texto latex
    #
    def converte_configuracao_para_latex
      @artigo_latex.merge!(@artigo)

      ['resumo','abstract','bibliografia'].each {|key|
        Open3.popen3("pandoc --smart -f markdown -t latex --no-wrap") {|stdin, stdout, stderr, wait_thr|
          pid = wait_thr.pid # pid of the started process.
          stdin.write @artigo[key]
          stdin.close
          @artigo_latex[key] = stdout.read
        }
      }
    end

    def executa_com_configuracao
      converte_configuracao_para_latex
      salva_configuracao_yaml_para_inclusao_em_pandoc
      executa_pandoc_salvando_latex
      executa_pdflatex
    end

    def executa_pandoc_salvando_latex
      t = Formatafacil::Template.new()
      data_dir = t.directory

      Open3.popen3("pandoc --smart --standalone   --data-dir=#{data_dir} --template=#{modelo} -f markdown -t latex -o #{@arquivo_saida_latex}") {|stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid # pid of the started process.
        stdin.write @texto
        # yaml com metados:
        stdin.write "\n"
        stdin.write @artigo_latex.to_yaml
        stdin.write("---\n")

        stdin.close
        # stdout.read
      }
      # system "pandoc --smart -s #{@arquivo_texto} #{@arquivo_saida_yaml}  --data-dir=#{data_dir} --template=#{modelo} -f markdown -t latex -o #{@arquivo_saida_latex}"
    end

    def executa_pdflatex
      #system "pdflatex #{@arquivo_saida_latex}"
      #system "pdflatex #{@arquivo_saida_latex}"
    end

    # Precisa gerar arquivos com quebra de linha antes e depois
    # porque pandoc utiliza
    def salva_configuracao_yaml_para_inclusao_em_pandoc
      File.open(@arquivo_saida_yaml, 'w'){ |file|
        file.write("\n")
        file.write @artigo_latex.to_yaml
        file.write("---\n")
      }
    end



  end
end
