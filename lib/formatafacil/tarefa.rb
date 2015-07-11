module Formatafacil
  class Tarefa

    
    def initialize(h={})
      h.each {|k,v| send("#{k}=",v)}
    end
    
    def executa
    end
    
  end
end
