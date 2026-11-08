// fMobilidade — tabela fato mensal tratada e reconciliada com a Etapa 1 (33 meses válidos)
let
    Origem = stg_Mobilidade_Bruto,

    // --- Atividade 3: Remover linhas totalmente em branco e campos obrigatórios vazios (D5) ---
    SemLinhasEmBranco = Table.SelectRows(Origem, each not List.IsEmpty(
        List.RemoveMatchingItems(Record.FieldValues(Record.SelectFields(_, ColunasAlvo)), {"", null}))),

    SemCamposVazios = Table.SelectRows(SemLinhasEmBranco, each
        [Ano] <> null and Text.Trim(Text.From([Ano])) <> "" and
        [Mês] <> null and Text.Trim(Text.From([Mês])) <> "" and
        [Grupo Estrutural] <> null and Text.Trim(Text.From([Grupo Estrutural])) <> "" and
        [Grupo Local de Articulação Regional] <> null and Text.Trim(Text.From([Grupo Local de Articulação Regional])) <> "" and
        [Grupo Local de Distribuição] <> null and Text.Trim(Text.From([Grupo Local de Distribuição])) <> "" and
        [Total publicado] <> null and Text.Trim(Text.From([Total publicado])) <> ""),

    // --- Atividade 4: Conversão de tipos numéricos pt-BR (D6) e validação de Data/Período (D1) ---
    NumerosConvertidos = Table.TransformColumns(SemCamposVazios, {
        {"Ano", fnNumeroInteiro, Int64.Type},
        {"Mês", fnNumeroInteiro, Int64.Type},
        {"Grupo Estrutural", fnNumeroInteiro, Int64.Type},
        {"Grupo Local de Articulação Regional", fnNumeroInteiro, Int64.Type},
        {"Grupo Local de Distribuição", fnNumeroInteiro, Int64.Type},
        {"Total publicado", fnNumeroInteiro, Int64.Type}
    }),

    SemNaoNumericos = Table.SelectRows(NumerosConvertidos, each
        [Ano] <> null and [Mês] <> null and
        [Grupo Estrutural] <> null and [Grupo Local de Articulação Regional] <> null and
        [Grupo Local de Distribuição] <> null and [Total publicado] <> null),

    ComDataTrat = Table.AddColumn(SemNaoNumericos, "Data_Trat", each fnDataMes([Ano], [Mês]), type nullable date),
    SemDataInvalida = Table.SelectRows(ComDataTrat, each [Data_Trat] <> null),
    NoPeriodo = Table.SelectRows(SemDataInvalida, each [Data_Trat] >= #date(2024, 1, 1) and [Data_Trat] <= #date(2026, 9, 1)),

    ValoresPositivos = Table.SelectRows(NoPeriodo, each
        [Grupo Estrutural] > 0 and [Grupo Local de Articulação Regional] > 0 and
        [Grupo Local de Distribuição] > 0 and [Total publicado] > 0),

    // --- Atividade 5 e 6: Chave de período, deduplicação (D8) e mesclagem com dGrupo/cad_DePara (D4/D7) ---
    ComChavePeriodo = Table.AddColumn(ValoresPositivos, "Chave_Periodo", each
        Text.From([Ano]) & "-" & Text.PadStart(Text.From([Mês]), 2, "0"), type text),

    OrdemOriginal = Table.Buffer(Table.Sort(ComChavePeriodo, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})),
    SemDuplicatas = Table.Distinct(OrdemOriginal, {"Chave_Periodo"}),

    // Identifica o grupo de maior demanda no mês (mesma regra de Grupo_Referencia da Etapa 1)
    ComNomeMaiorGrupo = Table.AddColumn(SemDuplicatas, "Chave_Grupo_Ref", each
        let
            MaxVal = List.Max({[Grupo Estrutural], [Grupo Local de Articulação Regional], [Grupo Local de Distribuição]}),
            NomeGrp = if [Grupo Estrutural] = MaxVal then "GRUPO ESTRUTURAL"
                      else if [Grupo Local de Articulação Regional] = MaxVal then "GRUPO LOCAL DE ARTICULAÇÃO REGIONAL"
                      else "GRUPO LOCAL DE DISTRIBUIÇÃO"
        in
            NomeGrp, type text),

    MesclaGrupo = Table.NestedJoin(ComNomeMaiorGrupo, {"Chave_Grupo_Ref"}, cad_GrupoChave, {"Chave_Grupo"}, "CadGrupo", JoinKind.LeftOuter),
    ExpandeGrupo = Table.ExpandTableColumn(MesclaGrupo, "CadGrupo",
        {"Cod_Grupo", "Nome_Padronizado", "Categoria"},
        {"Cod_Grupo_Referencia", "Grupo_Referencia", "Categoria_Cad"}),
    ComCadastroValido = Table.SelectRows(ExpandeGrupo, each [Cod_Grupo_Referencia] <> null),

    // --- Atividade 7: Colunas personalizadas (Total_Calculado, Diferenca, Status_Total e Participações) ---
    ComTotalCalculado = Table.AddColumn(ComCadastroValido, "Total_Calculado", each
        [Grupo Estrutural] + [Grupo Local de Articulação Regional] + [Grupo Local de Distribuição], Int64.Type),

    ComDiferenca = Table.AddColumn(ComTotalCalculado, "Diferenca", each
        [Total_Calculado] - [Total publicado], Int64.Type),

    // Divergência em Jul/26 (+10.000) e Set/26 (-10.000.000) não descarta a linha (análogo ao D9 do CaféData: preservado e auditado)
    ComStatusTotal = Table.AddColumn(ComDiferenca, "Status_Total", each
        if [Diferenca] = 0 then "OK" else "Divergente", type text),

    ComPartEstrutural = Table.AddColumn(ComStatusTotal, "Part_Estrutural", each
        Number.Round([Grupo Estrutural] / [Total_Calculado], 6), type number),

    ComPartArticulacao = Table.AddColumn(ComPartEstrutural, "Part_Articulacao", each
        Number.Round([Grupo Local de Articulação Regional] / [Total_Calculado], 6), type number),

    ComPartDistribuicao = Table.AddColumn(ComPartArticulacao, "Part_Distribuicao", each
        Number.Round([Grupo Local de Distribuição] / [Total_Calculado], 6), type number),

    FormatoFinal = Table.SelectColumns(ComPartDistribuicao, {
        "Chave_Periodo", "Data_Trat", "Ano", "Mês",
        "Grupo Estrutural", "Grupo Local de Articulação Regional", "Grupo Local de Distribuição",
        "Total publicado", "Total_Calculado", "Diferenca", "Status_Total",
        "Part_Estrutural", "Part_Articulacao", "Part_Distribuicao",
        "Cod_Grupo_Referencia", "Grupo_Referencia", "Categoria_Cad",
        "Arquivo_Origem", "Linha_Origem"
    })
in
    FormatoFinal
