# encoding: utf-8

module Formatafacil
  class Tarefa
    attr_accessor :logger
    
    def initialize(h={})
      h.each {|k,v| send("#{k}=",v)}
    end
    
    def executa
    end
    
    
    def self.arquivo_configuracao
      'config/1-configuracoes-gerais.yaml'
    end

    
  end
end
