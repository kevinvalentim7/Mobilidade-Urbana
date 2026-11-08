// fnLerMobilidade — lê, padroniza cabeçalhos e numera as linhas de cada arquivo anual (Linha_Origem começa em 2)
(conteudo as binary) as table =>
let
    Planilha    = fnLerPlanilha(conteudo),
    Padronizada = fnPadronizarColunas(Planilha),
    ComLinha    = Table.AddIndexColumn(Padronizada, "Linha_Origem", 2, 1, Int64.Type)
in
    ComLinha
