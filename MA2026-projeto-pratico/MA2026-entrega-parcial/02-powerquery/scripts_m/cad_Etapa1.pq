// cad_Etapa1 — lista todas as abas e tabelas do arquivo da Etapa 1
let
    Fonte = Excel.Workbook(File.Contents(pArquivoEtapa1), null, true)
in
    Fonte
