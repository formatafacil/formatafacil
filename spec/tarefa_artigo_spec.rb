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

  context "Gera arquivos latex a partir de textos markdown" do
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
      bibliografia =<<eos
SOBRENOME, nome. *Título da referência*. Data.
eos
      @tarefa = Formatafacil::ArtigoTarefa.new(modelo: "artigo-abnt", texto: texto, 'resumo' => @resumo, abstract: @abstract, metadados: YAML.load(@metadados), bibliografia: @bibliografia)

      @buffer = StringIO.new()
      allow(File).to receive(:open).with(tarefa.arquivo_saida_latex,'w').and_yield( @buffer )
      @tarefa.executa
    end

    it "Mesmo resumo" do
      expect(@tarefa.resumo).to equal(@resumo)
    end


    it "Arquivo latex foi criado" do
      expect(@buffer).not_to be_empty
    end

    it "Gera um arquivo latex com a conversão apropriada" do
      File.open(@tarefa.arquivo_saida_latex, 'r') do |f|
        latex_text = f.read
        expect(latex_text).to include("\\section{Primeira seção aqui}")
      end
    end

  end


  context "Quando os arquivos possuem blocos de metadados" do
    context "No arquivo principal do artigo" do
      before do
        texto = <<TEXTO
Exemplo de texto de um arquivo de texto,

---
nome_do_parametro: "valor do  parâmetro"
numero: 15
boo_true: true
boo_false: false
boo_sim: sim
boo_nao: não
---

O texto continua  aqui.
TEXTO
        Tempfile.open('abstract') do |file|
          file.write(texto)
          file.close
          @hash = subject.ler_metadados_do_arquivo(file.path)
        end
      end

      it "Salva as variáveis no hash 'artigo'" do
        expect(@hash).to eq({'nome_do_parametro' => 'valor do parâmetro', 'numero'=>'15', 'boo_true'=> true, 'boo_false'=>false, 'boo_sim'=> true, 'boo_nao'=>false})
      end
    end

  end

  it 'ler metadados inseridos diretamente nos arquivos específicos' do
    texto = <<TEXTO
Exemplo de texto de um arquivo de configuração

---
nome_do_parametro: "valor do  parâmetro"
numero: 15
boo_true: true
boo_false: false
boo_sim: sim
boo_nao: não
---
TEXTO

    Tempfile.open('abstract') do |file|
      file.write(texto)
      file.close
      t = Formatafacil::ArtigoTarefa.new
      expect(t.ler_metadados_do_arquivo(file.path)).to eq({'nome_do_parametro' => 'valor do parâmetro', 'numero'=>'15', 'boo_true'=> true, 'boo_false'=>false, 'boo_sim'=> true, 'boo_nao'=>false})
    end

  end

  it 'especifica um modelo para geração do artigo' do
    tarefa = Formatafacil::ArtigoTarefa.new(:modelo => 'abnt')
    expect(tarefa.modelo).to eq("abnt")
  end

  it 'gera um arquivo latex e compila pdf com o formato de artigo apropriado' do
    tarefa = Formatafacil::ArtigoTarefa.new(:modelo => 'artigo-abnt')

    Dir.mktmpdir() { |dir|
      Dir.chdir(dir){
        criaExemploDeArtigo(tarefa)
        #tarefa.executa

        #expect(tarefa.artigo['resumo']).to eq("**meu-resumo**\n")
        #expect(tarefa.artigo_latex['resumo']).to eq("\\textbf{meu-resumo}\n")

        #expect(File.file?('artigo.yaml')).to eq(true)
        #result = YAML.load_file(tarefa.arquivo_saida_yaml)
        #expect(result['resumo']).to eq("\\textbf{meu-resumo}\n")

        #expect(File.file?(tarefa.arquivo_latex)).to eq(true)
        #expect(File.file?(tarefa.arquivo_pdf)).to eq(true)
      }
    }
  end



  it 'gera um artigo latex com o template apropriado' do
    tarefa = Formatafacil::ArtigoTarefa.new(:modelo => 'artigo-abnt')

    palavras_chave = "um. dois. três."
    dentro_do_resumo = "Segue texto que deve vir dentro do resumo."
    resumo = <<RESUMO
Este é o resumo do meu artigo, ele pode conter
entre 150 a 500 palavras ou **words**.
#{dentro_do_resumo}

**Palavras-chave**: #{palavras_chave}
RESUMO

    keywords = 'latex. abntex. formatafacil.'
    titulo_em_ingles= 'English title'
    abstract = <<ABSTRACT
---
titulo_em_ingles: "#{titulo_em_ingles}"
---

According to ABNT NBR 6022:2003, an abstract in foreign language is a back
matter mandatory element.

**Keywords**: #{keywords}

ABSTRACT



    titulo_da_obra = "Título da Obra"
    autores = "Nome-do-autor"
    data = "18/07/2015"
    titulo_da_secao = "Primeira seção"
    primeiro_paragrafo = "Texto do primeiro parágrafo!"
    citacao = "Minha citação aqui."
    texto = <<TEXTO
\% #{titulo_da_obra}
\% #{autores}
\% #{data}

# #{titulo_da_secao}

#{primeiro_paragrafo}

> #{citacao}

TEXTO

    bibliografia = <<BIBLIOGRAFIA
# Referências

GOMES, L. G. F. F. *Novela e sociedade no Brasil*. Niterói: EdUFF,
1998. 137 p., 21 cm. (Coleção Antropologia e Ciência Política, 15).
Bibliografia: p. 131-132. ISBN 85-228-0268-8.

BIBLIOGRAFIA

    Dir.mktmpdir() { |dir| Dir.chdir(dir){
      Dir.mkdir('config')
      cria_arquivo_texto(tarefa, texto)
      expect(File.file?(tarefa.arquivo_texto)).to eq(true)
      cria_arquivo_resumo(tarefa, resumo)
      expect(File.file?(tarefa.arquivo_resumo)).to eq(true)
      cria_arquivo_abstract(tarefa, abstract)
      expect(File.file?(tarefa.arquivo_abstract)).to eq(true)
      cria_arquivo_bibliografia(tarefa, bibliografia)
      expect(File.file?(tarefa.arquivo_bibliografia)).to eq(true)

      tarefa.executa

      expect(File.file?('artigo.yaml')).to eq(true)
      result = YAML.load_file(tarefa.arquivo_saida_yaml)
      expect(result['resumo'].include?(dentro_do_resumo)).to eq(true)

      expect(tarefa.artigo_latex['resumo'].include?(dentro_do_resumo)).to eq(true)
      expect(tarefa.artigo['titulo_em_ingles']).to eq(titulo_em_ingles)

      expect(File.file?(tarefa.arquivo_saida_latex)).to eq(true)
      conteudo = ""
      File.open(tarefa.arquivo_saida_latex, 'r') { |f| conteudo = f.read }

      expect(conteudo.include?('abnTeX2')).to eq(true)
      expect(conteudo.include?(titulo_da_obra)).to eq(true)
      expect(conteudo.include?(autores)).to eq(true)

      expect(conteudo.include?(data)).to eq(true)
      expect(conteudo.include?(dentro_do_resumo)).to eq(true)
      expect(conteudo.include?("\\textbf{words}")).to eq(true)

      expect(conteudo.include?("\\titulo{#{titulo_da_obra}}")).to eq(true)
      expect(conteudo.include?(titulo_da_secao)).to eq(true)
      expect(conteudo.include?("\\section{#{titulo_da_secao}}")).to eq(true)
      expect(conteudo.include?(primeiro_paragrafo)).to eq(true)
      expect(conteudo.include?("\\begin{quote}\n#{citacao}\n\\end{quote}")).to eq(true)

      expect(conteudo.include?("GOMES")).to eq(true)

      usar_ingles = true
      expect(conteudo.include?(titulo_em_ingles)).to eq(usar_ingles)
      expect(conteudo.include?(keywords)).to eq(usar_ingles)
      #expect(conteudo).to eq("")

    }}
  end

    it 'How to mock File.open for write with rspec 3.4', :learning do
      @buffer = StringIO.new()
      @filename = "somefile.txt"
      @content = "the content fo the file"
      allow(File).to receive(:open).with(@filename,'w').and_yield( @buffer )

      File.open(@filename, 'w') {|f| f.write(@content)}

      expect(@buffer.string).to eq(@content)
    end



end
