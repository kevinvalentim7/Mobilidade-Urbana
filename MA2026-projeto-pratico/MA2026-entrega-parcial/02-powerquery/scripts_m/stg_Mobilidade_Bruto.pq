// stg_Mobilidade_Bruto — lê todos os arquivos .xlsx da pasta, ignora temporários (~$) e empilha com rastreabilidade
let
    Origem = Folder.Files(pPastaMobilidade),
    SoPlanilhas = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".xlsx" and not Text.StartsWith([Name], "~$")),
    ComDados = Table.AddColumn(SoPlanilhas, "Dados", each fnLerMobilidade([Content])),
    SoNomeEDados = Table.SelectColumns(ComDados, {"Name", "Dados"}),
    Renomeada = Table.RenameColumns(SoNomeEDados, {{"Name", "Arquivo_Origem"}}),
    Anexada = Table.ExpandTableColumn(Renomeada, "Dados", ColunasAlvo & {"Linha_Origem"}),
    Ordenada = Table.Sort(Anexada, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
