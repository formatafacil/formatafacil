module Formatafacil
  class Artigo
    attr_accessor 'arquivo_entrada_padrao'
    attr_accessor 'arquivo_resumo'
    attr_accessor 'arquivo_abstract'

    
    def initialize(h)
      h.each {|k,v| send("#{k}=",v)}
    end
    
   def initialize()
      @arquivo_entrada_padrao = 'artigo.md'
      @arquivo_resumo = 'config/resumo.md'
      @arquivo_abstract = 'config/abstract.md'
   end
       
  end
end
