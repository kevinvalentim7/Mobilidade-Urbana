// Conf_Reconciliacao — prova que Linhas Lidas - Aceitas - Rejeitadas = 0
let
    Lidas = Table.RowCount(stg_Mobilidade_Bruto),
    Aceitas = Table.RowCount(fMobilidade),
    Rejeitadas = Table.RowCount(Rejeitados),
    Resultado = #table(type table [Indicador = text, Linhas = Int64.Type], {
        {"1. Linhas lidas (todos os arquivos)", Lidas},
        {"2. Aceitas em fMobilidade", Aceitas},
        {"3. Registradas em Rejeitados", Rejeitadas},
        {"4. Diferença (1 - 2 - 3): deve ser 0", Lidas - Aceitas - Rejeitadas}
    })
in
    Resultado
