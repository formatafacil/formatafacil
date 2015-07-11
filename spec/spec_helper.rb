$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'formatafacil'


def criaExemploDeArtigo(tarefa)
  
  Dir.mkdir 'config'
  
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