// Conf_Colunas — verifica se alguma coluna dos arquivos brutos ficou sem mapeamento em DeParaColunas
let
    Origem = Folder.Files(pPastaMobilidade),
    SoPlanilhas = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".xlsx" and not Text.StartsWith([Name], "~$")),
    Pares = List.Zip({DeParaColunas[Nome_Origem], DeParaColunas[Nome_Alvo]}),
    NaoMapeadas = Table.AddColumn(SoPlanilhas, "Colunas_Nao_Mapeadas", each
        let
            Cab = Table.ColumnNames(Table.RenameColumns(
                Table.TransformColumnNames(fnLerPlanilha([Content]), Text.Trim),
                Pares, MissingField.Ignore))
        in
            Text.Combine(List.Difference(Cab, ColunasAlvo), ", "), type text),
    Resultado = Table.SelectColumns(NaoMapeadas, {"Name", "Colunas_Nao_Mapeadas"})
in
    Resultado
