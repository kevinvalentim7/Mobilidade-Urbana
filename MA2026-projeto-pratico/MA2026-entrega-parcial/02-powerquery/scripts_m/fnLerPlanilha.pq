// fnLerPlanilha — devolve a primeira aba (Sheet) de um arquivo .xlsx com cabeçalhos promovidos
(conteudo as binary) as table =>
let
    Pasta = Excel.Workbook(conteudo, true),
    Abas  = Table.SelectRows(Pasta, each [Kind] = "Sheet"),
    Dados = Abas{0}[Data]
in
    Dados
