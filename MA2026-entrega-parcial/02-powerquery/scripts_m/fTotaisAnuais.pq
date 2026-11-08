// fTotaisAnuais — despivota os totais anuais publicados pela SPTrans e cruza com a soma dos meses tratados
let
    Fonte = Excel.Workbook(File.Contents(pArquivoTotaisAnuais), true),
    Planilha = Table.SelectRows(Fonte, each [Kind] = "Sheet"){0}[Data],
    SemColunaTotal = Table.RemoveColumns(Planilha, {"Total"}, MissingField.Ignore),
    Despivotada = Table.UnpivotOtherColumns(SemColunaTotal, {"Ano"}, "Grupo_Origem", "Total_Anual_Publicado"),
    Tipos = Table.TransformColumnTypes(Despivotada, {{"Ano", Int64.Type}, {"Grupo_Origem", type text}, {"Total_Anual_Publicado", Int64.Type}}, "pt-BR"),
    ComChave = Table.AddColumn(Tipos, "Chave_Grupo", each Text.Upper(Text.Trim([Grupo_Origem])), type text),
    MesclaGrupo = Table.NestedJoin(ComChave, {"Chave_Grupo"}, cad_GrupoChave, {"Chave_Grupo"}, "Cad", JoinKind.LeftOuter),
    ExpandeGrupo = Table.ExpandTableColumn(MesclaGrupo, "Cad", {"Cod_Grupo", "Nome_Padronizado"}, {"Cod_Grupo", "Grupo_Padronizado"}),
    SomaMensal = Table.Group(fPassageirosGrupo, {"Ano", "Cod_Grupo"}, {{"Soma_Meses_Tratados", each List.Sum([Passageiros]), Int64.Type}}),
    MesclaSoma = Table.NestedJoin(ExpandeGrupo, {"Ano", "Cod_Grupo"}, SomaMensal, {"Ano", "Cod_Grupo"}, "Mensal", JoinKind.LeftOuter),
    ExpandeSoma = Table.ExpandTableColumn(MesclaSoma, "Mensal", {"Soma_Meses_Tratados"}, {"Soma_Meses_Tratados"}),
    ComDiferenca = Table.AddColumn(ExpandeSoma, "Diferenca_Anual", each [Soma_Meses_Tratados] - [Total_Anual_Publicado], Int64.Type),
    ComAnoInicio = Table.AddColumn(ComDiferenca, "Ano_Inicio", each #date([Ano], 1, 1), type date),
    FormatoFinal = Table.SelectColumns(ComAnoInicio, {
        "Ano", "Cod_Grupo", "Grupo_Padronizado",
        "Total_Anual_Publicado", "Soma_Meses_Tratados", "Diferenca_Anual", "Ano_Inicio"
    })
in
    FormatoFinal
