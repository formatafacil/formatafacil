$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'formatafacil'
require 'formatafacil/tarefa'
require 'tmpdir'
require 'yaml'

def criaExemploDeArtigo(tarefa)
  texto = "meu-texto"
  resumo = "**meu-resumo**\n"
  abstract = 'my-abstract'
  File.open(tarefa.arquivo_texto, 'w'){ |file| file.write (texto)}
  File.open(tarefa.arquivo_resumo, 'w'){ |file| file.write (resumo)}
  File.open(tarefa.arquivo_abstract, 'w'){ |file| file.write (abstract)}

  #verifica que os arquivos foram criados
  expect(File.file?(tarefa.arquivo_texto)).to eq(true)
  expect(File.file?(tarefa.arquivo_texto)).to eq(true)
  expect(File.file?(tarefa.arquivo_texto)).to eq(true)
end


def cria_arquivo_configuracao(hash)
  unless File.directory?('config')
    FileUtils.mkdir_p('config')
  end
  File.open(Formatafacil::Tarefa.arquivo_configuracao, 'w'){ |file| file.write(hash.to_yaml)}
end

def cria_arquivo(arquivo, string)
  File.open(arquivo, 'w'){ |file| file.write string }
end

def cria_arquivo_texto(t,string)
  cria_arquivo(t.arquivo_texto, string)
end
def cria_arquivo_resumo(t,string)
  cria_arquivo(t.arquivo_resumo, string)
end
def cria_arquivo_abstract(t,string)
  cria_arquivo(t.arquivo_abstract, string)
end
def cria_arquivo_bibliografia(t,string)
  cria_arquivo(t.arquivo_bibliografia, string)
end
