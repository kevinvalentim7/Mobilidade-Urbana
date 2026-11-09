// Rejeitados — anti-junção esquerda (stg_Mobilidade_Bruto vs fMobilidade) com diagnóstico na mesma ordem de regras
let
    Origem = stg_Mobilidade_Bruto,

    // 1. Linhas lidas que NÃO estão em fMobilidade (JoinKind.LeftAnti)
    Mescla = Table.NestedJoin(Origem, {"Arquivo_Origem", "Linha_Origem"},
        fMobilidade, {"Arquivo_Origem", "Linha_Origem"}, "Aceita", JoinKind.LeftAnti),
    SoRejeitadas = Table.RemoveColumns(Mescla, {"Aceita"}),

    // 2. Funções auxiliares de diagnóstico
    EVazio = (v) => v = null or Text.Trim(Text.From(v)) = "",
    ENumero = (v) => fnNumeroInteiro(v) <> null,

    // 3. Mesma ordem de regras de fMobilidade: o primeiro teste que falha é o motivo
    Diagnostico = (r as record) as text =>
        let
            Valores = List.RemoveMatchingItems(Record.FieldValues(Record.SelectFields(r, ColunasAlvo)), {"", null}),
            Data = fnDataMes(r[Ano], r[Mês])
        in
            if List.IsEmpty(Valores) then "Linha em branco"
            else if EVazio(r[Ano]) or EVazio(r[Mês]) or EVazio(r[Grupo Estrutural])
                 or EVazio(r[Grupo Local de Articulação Regional]) or EVazio(r[Grupo Local de Distribuição])
                 or EVazio(r[Total publicado]) then "Campo obrigatório vazio"
            else if not (ENumero(r[Ano]) and ENumero(r[Mês]) and ENumero(r[Grupo Estrutural])
                 and ENumero(r[Grupo Local de Articulação Regional]) and ENumero(r[Grupo Local de Distribuição])
                 and ENumero(r[Total publicado])) then "Valor não numérico"
            else if Data = null then "Data ou mês inválido"
            else if Data < #date(2024, 1, 1) or Data > #date(2026, 9, 1) then "Data fora do período"
            else if fnNumeroInteiro(r[Grupo Estrutural]) <= 0
                 or fnNumeroInteiro(r[Grupo Local de Articulação Regional]) <= 0
                 or fnNumeroInteiro(r[Grupo Local de Distribuição]) <= 0
                 or fnNumeroInteiro(r[Total publicado]) <= 0 then "Valores zerados ou negativos"
            else "Período duplicado",

    ComMotivo = Table.AddColumn(SoRejeitadas, "Motivo", each Diagnostico(_), type text),
    Ordenada = Table.Sort(ComMotivo, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
