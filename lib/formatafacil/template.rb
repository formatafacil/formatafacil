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
    
    def executa
    end
      
    # $LOAD_PATH.each { |dir|  ... look for resources relative to dir ... }
    def list
      modelos.keys
    end
  end
    
end
