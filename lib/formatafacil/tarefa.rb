# encoding: utf-8

module Formatafacil
  class Tarefa
    attr_accessor :logger

    def initialize(h={})
      h.each {|k,v| send("#{k}=",v)}
    end

    def executa
    end

  end
end
