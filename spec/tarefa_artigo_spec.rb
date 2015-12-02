require 'spec_helper'
require 'formatafacil/artigo_tarefa'
require 'tmpdir'
require 'yaml'
#require 'io'

describe Formatafacil::ArtigoTarefa do

  context "Quando criada" do
    it "Possui configuração padrão para o nome do arquivo de resumo: resumo.md" do
      expect(subject.arquivo_resumo()).to eq("resumo.md")
    end
    it "Possui configuração padrão para o nome do arquivo de abstract: abstract.md" do
      expect(subject.arquivo_abstract()).to eq("abstract.md")
    end
    it "Possui configuração padrão para o nome do arquivo de bibliografia: bibliografia.md" do
      expect(subject.arquivo_bibliografia).to eq("bibliografia.md")
    end

    it "Não possui metadados (hash vazio)" do
      expect(subject.metadados).to be_empty
      expect(subject.metadados).to be_a(Hash)
    end

    context "Com um modelo específico" do
      let(:subject) { Formatafacil::ArtigoTarefa.new({:modelo=>'artigo-abnt'}) }
      it "Utiliza o nome do modelo como arquivo de texto: artigo-abnt.md" do
        expect(subject.arquivo_texto).to eq("artigo-abnt.md")
      end
    end
  end

  it "Consulta os modelos de artigos instalados de formatafacil-templates" do
    expect(subject.modelos).not_to be_empty
  end

  context "Quando passamos os conteúdos programaticamente" do
    before do
      @modelo = "artigo-abnt"
      @texto = <<eos
# Primeira seção aqui
Texto da seção aqui.

# Segunda seção
Texto da seção aqui.
eos
      @resumo = <<eos
Segue texto do *resumo aqui*.
eos
      @abstract =<<eos
This is the text of the *abstract*.

---
titulo_em_ingles: "English title"
---
eos
      @metadados = {'titulo' => "Título do artigo", 'autores'=> "Autor do artigo", 'data'=> "2015"}
      @bibliografia =<<eos
SOBRENOME, nome. *Título da referência*. Data.
eos
      @tarefa = Formatafacil::ArtigoTarefa.new(modelo: @modelo, texto: @texto, 'resumo' => @resumo, abstract: @abstract, metadados: @metadados, bibliografia: @bibliografia)
    end

    context "Os dados são lidos corretamente" do
      it "Possui o mesmo valor para resumo" do
        expect(@tarefa.resumo).to eq(@resumo)
      end
      it "Possui o mesmo valor para abstract" do
        expect(@tarefa.abstract).to eq(@abstract)
      end
      it "Possui o mesmo valor para modelo" do
        expect(@tarefa.modelo).to eq(@modelo)
      end
      it "Possui o mesmo valor para metadados" do
        expect(@tarefa.metadados).to eq(@metadados)
      end
      it "Possui o mesmo valor para texto" do
        expect(@tarefa.texto).to eq(@texto)
      end
      it "Possui o mesmo valor para bibliografia" do
        expect(@tarefa.bibliografia).to eq(@bibliografia)
      end
    end

    context "Quando unifica metadados para incluir no modelo latex" do
      before do
        @tarefa.unifica_metadados
      end
      it "converte o texto de resumo para latex" do
        expect(@tarefa.converte_conteudo_para_latex(@resumo)).to eq("Segue texto do \\emph{resumo aqui}.")
      end
      it "converte o texto de abstract para latex" do
        expect(@tarefa.converte_conteudo_para_latex(@abstract)).to eq("This is the text of the \\emph{abstract}.")
      end
      it "converte a bibliografia para latex" do
        expect(@tarefa.converte_conteudo_para_latex(@bibliografia)).to eq("SOBRENOME, nome. \\emph{Título da referência}. Data.")
      end
      it "salva o resumo convertido (em latex) em 'metadados' " do
        #expect(@tarefa.metadados).to include({'resumo'=>@tarefa.converte_resumo_latex})
        expect(@tarefa.metadados).to include('resumo' => @tarefa.converte_conteudo_para_latex(@resumo))
      end
      it "salva o abstract convertido (em latex) em 'metadados' " do
        #expect(@tarefa.metadados).to include({'resumo'=>@tarefa.converte_resumo_latex})
        expect(@tarefa.metadados).to include('abstract' => @tarefa.converte_conteudo_para_latex(@abstract))
      end
      it "salva a bibliografia convertido (em latex) em 'metadados' " do
        #expect(@tarefa.metadados).to include({'resumo'=>@tarefa.converte_resumo_latex})
        expect(@tarefa.metadados).to include('bibliografia' => @tarefa.converte_conteudo_para_latex(@bibliografia))
      end
      it "salva as variáveis dos blocos yaml (de abstract) em 'metadados' " do
        #expect(@tarefa.metadados).to include({'resumo'=>@tarefa.converte_resumo_latex})
        expect(@tarefa.metadados).to include('titulo_em_ingles' => 'English title')
      end

      context "Quando exporta conteúdo em markdown" do
        before do
          @conteudo_markdown = @tarefa.exporta_conteudo_markdown
        end

        it "Contém o texto original" do
          expect(@conteudo_markdown).to include(@texto)
        end
        it "Contém um bloco YAML com os metadados (entre dois ---)" do
          expect(@conteudo_markdown).to include("\n#{@metadados.to_yaml}---\n")
        end
      end
    end

    context "Convertendo conteúdo para latex" do
      before do
        @tarefa.unifica_metadados
        @conteudo_latex = @tarefa.converte_artigo_para_latex
      end

      it "Contem os títulos em latex" do
        expect(@conteudo_latex).to include("\\section{Primeira seção aqui}")
        expect(@conteudo_latex).to include("\\section{Segunda seção}")
      end

      it "Contem o resumo em latex" do
        RESUMO_LATEX =<<eos
\\begin{resumoumacoluna}

Segue texto do \\emph{resumo aqui}.

\\end{resumoumacoluna}
eos
        expect(@conteudo_latex).to include(@tarefa.converte_conteudo_para_latex(@resumo))
        expect(@conteudo_latex).to include(RESUMO_LATEX)
      end

      it "Contem o abstract em latex" do
        ABSTRACT_LATEX =<<eos
\\renewcommand{\\resumoname}{Abstract}
\\begin{resumoumacoluna}
 \\begin{otherlanguage*}{english}
   This is the text of the \\emph{abstract}.
 \\end{otherlanguage*}
\\end{resumoumacoluna}
eos
        expect(@conteudo_latex).to include(ABSTRACT_LATEX)
      end

    end
  end

  context "Quando os conteúdos são lidos de arquivos", :wip do
    before do
      @modelo = "artigo-abnt"
      @texto = <<eos
# Primeira seção aqui
Texto da seção aqui.

# Segunda seção
Texto da seção aqui.
eos
      @resumo = <<eos
Segue texto do *resumo aqui*.
eos
      @abstract =<<eos
This is the text of the *abstract*.

---
titulo_em_ingles: "English title"
---
eos
      @metadados =<<eos
---
titulo: "Título do artigo"
autores: "Autor do artigo"
data: "2015"
---
eos

      @bibliografia =<<eos
SOBRENOME, nome. *Título da referência*. Data.
eos

      allow(File).to receive(:exist?).with("artigo-abnt.md") {true}
      allow(File).to receive(:open).with('artigo-abnt.md','r').and_yield( StringIO.new(@texto) )
      allow(File).to receive(:open).with('resumo.md','r').and_yield( StringIO.new(@resumo) )
      allow(File).to receive(:open).with('abstract.md','r').and_yield( StringIO.new(@abstract) )
      allow(File).to receive(:open).with('bibliografia.md','r').and_yield( StringIO.new(@bibliografia) )
      allow(File).to receive(:open).with('metadados.yaml','r').and_yield( StringIO.new(@metadados) )
      @buffer = StringIO.new()
      allow(File).to receive(:open).with("artigo.tex",'w').and_yield( @buffer )


      @tarefa = Formatafacil::ArtigoTarefa.new()
      @tarefa.executa()
    end
    after do
      FileUtils.rm_f %w(artigo-abnt.md resumo.md abstract.md bibliografia.md metadados.md)
    end

    it "O resumo foi lido corretamente" do
      expect(@tarefa.resumo).to eq(@resumo)
    end
    it "O abstract foi lido corretamente" do
      expect(@tarefa.abstract).to eq(@abstract)
    end
    it "A bibliografia foi lida corretamente" do
      expect(@tarefa.bibliografia).to eq(@bibliografia)
    end
    it "O arquivo de metadados foi lido corretamente" do
      expect(@tarefa.metadados).to include(YAML.load(@metadados))
    end

    it "Arquivo latex foi criado" do
      expect(@buffer.string).to include("Primeira seção aqui")
    end

    it "Arquivo latex inclui o resumo em latex" do
      expect(@buffer.string).to include(@tarefa.converte_conteudo_para_latex(@resumo))
    end

    it "Arquivo latex inclui o abstract em latex" do
      expect(@buffer.string).to include(@tarefa.converte_conteudo_para_latex(@abstract))
    end

    it "Arquivo latex inclui a bibliografia em latex" do
      expect(@buffer.string).to include(@tarefa.converte_conteudo_para_latex(@bibliografia))
    end

    it "Arquivo latex inclui o texto em latex" do
      expect(@buffer.string).to include(@tarefa.converte_conteudo_para_latex(@texto))
    end

  end

  context "Quando está faltando arquivo" do
    context "texto principal" do
      before do
        allow(File).to receive(:exist?).with("artigo-abnt.md") {false}
        @buffer = StringIO.new()
        allow(File).to receive(:open).with("artigo.tex",'w').and_yield( @buffer )
        @tarefa = Formatafacil::ArtigoTarefa.new()
      end
      it "imprime mensagem indicando que não encontrou um arquivo de texto" do
        expect{@tarefa.executa}.to raise_error(Formatafacil::ArquivoDeArtigoNaoEncontradoException, "Não possível encontrar um arquivo de artigo: [\"artigo-abnt.md\"]. Crie o arquivo com o nome do modelo apropriado e tente novamente.")
      end
    end
    context "resumo.md" do
      before do
        allow(File).to receive(:exist?).with("artigo-abnt.md") {true}
        allow(File).to receive(:open).with('artigo-abnt.md','r').and_yield(StringIO.new("texto"))
        allow(File).to receive(:open).with('resumo.md','r').and_raise(Formatafacil::ArquivoDeResumoNaoEncontradoError, "Não possível encontrar o arquivo de resumo: [\"resumo.md\"]. Crie o arquivo com o nome apropriado e tente novamente.")
        #allow(File).to receive(:open).with('abstract.md','r').and_yield( StringIO.new(@abstract) )
        #allow(File).to receive(:open).with('bibliografia.md','r').and_yield( StringIO.new(@bibliografia) )
        #allow(File).to receive(:open).with('metadados.yaml','r').and_yield( StringIO.new(@metadados) )
        @buffer = StringIO.new()
        allow(File).to receive(:open).with("artigo.tex",'w').and_yield( @buffer )
        @tarefa = Formatafacil::ArtigoTarefa.new()

      end
      it "imprime mensagem indicando que não encontrou o arquivo" do
        expect{@tarefa.executa}.to raise_error(Formatafacil::ArquivoDeResumoNaoEncontradoError, "Não possível encontrar o arquivo de resumo: [\"resumo.md\"]. Crie o arquivo com o nome apropriado e tente novamente.")
      end
    end
    context "abstract.md" do
      before do
        allow(File).to receive(:exist?).with("artigo-abnt.md") {true}
        allow(File).to receive(:open).with('artigo-abnt.md','r').and_yield(StringIO.new("texto"))
        allow(File).to receive(:open).with('resumo.md','r').and_yield(StringIO.new("resumo"))
        allow(File).to receive(:open).with('abstract.md','r').and_raise(Formatafacil::ArquivoNaoEncontradoError, "Não possível encontrar o arquivo de resumo: [\"abstract.md\"]. Crie o arquivo com o nome apropriado e tente novamente.")
        #allow(File).to receive(:open).with('abstract.md','r').and_yield( StringIO.new(@abstract) )
        #allow(File).to receive(:open).with('bibliografia.md','r').and_yield( StringIO.new(@bibliografia) )
        #allow(File).to receive(:open).with('metadados.yaml','r').and_yield( StringIO.new(@metadados) )
        @buffer = StringIO.new()
        allow(File).to receive(:open).with("artigo.tex",'w').and_yield( @buffer )
        @tarefa = Formatafacil::ArtigoTarefa.new()

      end
      it "imprime mensagem indicando que não encontrou o arquivo" do
        expect{@tarefa.executa}.to raise_error(Formatafacil::ArquivoNaoEncontradoError, "Não possível encontrar o arquivo de resumo: [\"abstract.md\"]. Crie o arquivo com o nome apropriado e tente novamente.")
      end
    end

  end

end
