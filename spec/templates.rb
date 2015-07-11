require 'spec_helper'
require 'formatafacil/template'

describe Formatafacil::Template do

  it 'lista os templates disponíveis' do
    templates = Formatafacil::Template.new()
    expect(templates.list).to eq(["artigo-abnt"])
  end

end
