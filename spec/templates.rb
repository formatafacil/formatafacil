require 'spec_helper'
require 'formatafacil/templates'

describe Formatafacil::Templates do

  it 'lista os templates disponíveis' do
    templates = Formatafacil::Templates.new()
    expect(templates.list).to eq(["artigo-abnt"])
  end

end
