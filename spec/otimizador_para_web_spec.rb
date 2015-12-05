require 'spec_helper'
require 'formatafacil/otimizador_para_web'
require 'securerandom'

describe Formatafacil::OtimizadorParaWeb do


  before(:example) do
    @arquivo = "#{SecureRandom.hex}.pdf"
  end

  context '#otimiza_pdf' do
    subject {Formatafacil::OtimizadorParaWeb.new(@arquivo)}
    before do
      allow(File).to receive(:rename) {}
      allow(File).to receive(:delete) {}
      allow(Kernel).to receive(:system) {}
      subject.otimiza_pdf
    end
    it 'invoca qpdf para otimizar o pdf para web', :i8 do
      expect(Kernel).to have_received(:system).with("qpdf --linearize bkp-#{@arquivo} #{@arquivo}") {}
    end
    it "renomeia o pdf original antes de efetuar a otimizacao", :i8 do
      expect(File).to have_received(:rename).with(@arquivo, "bkp-#{@arquivo}") {}
    end
    it "apaga o backup após otimização", :i8 do
      expect(File).to have_received(:delete).with("bkp-#{@arquivo}") {}
    end
  end

end
