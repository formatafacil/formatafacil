# encoding: utf-8
module Formatafacil
  class OtimizadorParaWeb

    attr_accessor :arquivo

    def initialize(arquivo)
      @arquivo=arquivo
    end
    
    def bkp_prefix(arquivo)
      "bkp-#{arquivo}"
    end
    
    def otimiza
      File.rename(@arquivo, bkp_prefix(@arquivo))
      system("qpdf --linearize #{bkp_prefix(@arquivo)} #{@arquivo}")
      File.delete(bkp_prefix(@arquivo))
    end
    
  end
end

