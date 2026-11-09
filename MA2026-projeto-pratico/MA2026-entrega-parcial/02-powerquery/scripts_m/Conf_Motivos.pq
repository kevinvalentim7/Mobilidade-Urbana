// Conf_Motivos — resumo de linhas rejeitadas por motivo
let
    Agrupada = Table.Group(Rejeitados, {"Motivo"}, {{"Linhas", each Table.RowCount(_), Int64.Type}}),
    Ordenada = Table.Sort(Agrupada, {{"Linhas", Order.Descending}, {"Motivo", Order.Ascending}})
in
    Ordenada
