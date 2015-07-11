require 'formatafacil/tarefa'


module Formatafacil
  class Templates < Tarefa
    
    attr_accessor 'modelos'
    
  
    def initialize()
      @modelos = {}

      
      $LOAD_PATH.each { |dir|  
        files = Dir["#{dir}/formatafacil/templates/*.tex"]
        files.each { |file| 
          if file
            modelos[File.basename(file, '.tex')] = file
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
