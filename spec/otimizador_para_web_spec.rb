require 'spec_helper'
require 'formatafacil/otimizador_para_web.rb'
require 'securerandom'

describe Formatafacil::OtimizadorParaWeb do
  
  
  before(:example) do
    @arquivo = "#{SecureRandom.hex}.pdf"
  end  
  
  it 'otimiza um pdf para web' do
    o = Formatafacil::OtimizadorParaWeb.new(@arquivo)
    allow(File).to receive(:rename) {}
    allow(File).to receive(:delete) {}

    expect(o).to receive(:system).with("qpdf --linearize bkp-#{@arquivo} #{@arquivo}") {}
    o.otimiza
  end

  it "renomeia o pdf original antes de efetuar a otimizacao e apaga o backup" do
    o = Formatafacil::OtimizadorParaWeb.new(@arquivo)
    allow(o).to receive(:system) {}
    expect(File).to receive(:rename).with(@arquivo, "bkp-#{@arquivo}") {}
    expect(File).to receive(:delete).with("bkp-#{@arquivo}") {}

    o.otimiza
  end
  

end
