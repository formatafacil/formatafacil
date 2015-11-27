# encoding: utf-8
require 'formatafacil/tarefa'


module Formatafacil
  class Template

    attr_accessor 'modelos'
    # Derectory of templates
    attr_accessor 'directory'

    def initialize()
      @modelos = {}

      # ler os templates do projeto formatafacil-templates
      $LOAD_PATH.each { |dir|
        files = Dir["#{dir}/formatafacil/templates/*.latex"]
        files.each { |file|
          if file
            @modelos[File.basename(file, '.tex')] = file
            @directory = "#{dir}/formatafacil"
          end
        }
      }

    end

    # Procura por um arquivo que possua o mesmo nome de um modelo.
    # Retorna o modelo com base no arquivo encontrado ou nil se não encontrou.
    # O nome do arquivo procurado será: "#{modelo}.md"
    def procura_modelo_de_artigo
      arquivo = nil
      artigo_modelos.each do |modelo|
        return modelo if File.exist?("#{modelo}.md")
      end
      arquivo
    end

    # $LOAD_PATH.each { |dir|  ... look for resources relative to dir ... }
    def list
      modelos.keys
    end

    def artigo_modelos
      modelos_de_artigos = []
      list_names.each do |modelo|
        modelos_de_artigos << modelo if modelo.start_with?('artigo')
      end
      modelos_de_artigos
    end

    def list_names
      names = []
      modelos.keys.each do |file|
        names << File.basename(file, ".latex")
      end
      names
    end
  end

end
