// fPassageirosGrupo — consulta em formato longo (despivota os 3 grupos de fMobilidade: 33 meses x 3 grupos = 99 linhas)
let
    Origem = fMobilidade,
    Selecionadas = Table.SelectColumns(Origem, {
        "Chave_Periodo", "Data_Trat", "Ano", "Mês", "Total_Calculado",
        "Arquivo_Origem", "Linha_Origem",
        "Grupo Estrutural", "Grupo Local de Articulação Regional", "Grupo Local de Distribuição"
    }),
    Despivotada = Table.UnpivotOtherColumns(Selecionadas,
        {"Chave_Periodo", "Data_Trat", "Ano", "Mês", "Total_Calculado", "Arquivo_Origem", "Linha_Origem"},
        "Grupo_Origem", "Passageiros"),
    ComChaveGrupo = Table.AddColumn(Despivotada, "Chave_Grupo", each Text.Upper(Text.Trim([Grupo_Origem])), type text),
    MesclaCadastro = Table.NestedJoin(ComChaveGrupo, {"Chave_Grupo"}, cad_GrupoChave, {"Chave_Grupo"}, "Cad", JoinKind.LeftOuter),
    ExpandeCadastro = Table.ExpandTableColumn(MesclaCadastro, "Cad",
        {"Cod_Grupo", "Nome_Padronizado", "Categoria"},
        {"Cod_Grupo", "Grupo_Padronizado", "Categoria"}),
    ComParticipacao = Table.AddColumn(ExpandeCadastro, "Participacao_Mes", each
        Number.Round([Passageiros] / [Total_Calculado], 6), type number),
    RenomeiaData = Table.RenameColumns(ComParticipacao, {{"Data_Trat", "Data"}}),
    FormatoFinal = Table.SelectColumns(RenomeiaData, {
        "Chave_Periodo", "Data", "Ano", "Mês",
        "Cod_Grupo", "Grupo_Padronizado", "Categoria",
        "Passageiros", "Participacao_Mes",
        "Arquivo_Origem", "Linha_Origem"
    })
in
    FormatoFinal
