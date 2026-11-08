// fnPadronizarColunas — resolve o defeito D10 (limpa cabeçalhos, renomeia via DeParaColunas e reordena via ColunasAlvo)
(tabela as table) as table =>
let
    CabecalhosLimpos = Table.TransformColumnNames(tabela, Text.Trim),
    Pares            = List.Zip({DeParaColunas[Nome_Origem], DeParaColunas[Nome_Alvo]}),
    Renomeada        = Table.RenameColumns(CabecalhosLimpos, Pares, MissingField.Ignore),
    NoFormatoAlvo    = Table.SelectColumns(Renomeada, ColunasAlvo, MissingField.UseNull)
in
    NoFormatoAlvo
