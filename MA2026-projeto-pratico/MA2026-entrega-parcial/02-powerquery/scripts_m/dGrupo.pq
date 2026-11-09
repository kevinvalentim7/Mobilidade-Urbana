// dGrupo — dimensão de grupos de transporte (Tab_Grupos + Tab_DePara da Etapa 1)
let
    Fonte = cad_Etapa1{[Item = "Tab_Grupos", Kind = "Table"]}[Data],
    Renomeada = Table.RenameColumns(Fonte, {{"Código", "Cod_Grupo"}, {"Grupo de transporte", "Grupo_Transporte"}}),
    Tipos = Table.TransformColumnTypes(Renomeada, {{"Cod_Grupo", type text}, {"Grupo_Transporte", type text}, {"Categoria", type text}, {"Unidade", type text}}),
    MesclaDePara = Table.NestedJoin(Tipos, {"Cod_Grupo"}, cad_DePara, {"Cod_Grupo"}, "DePara", JoinKind.LeftOuter),
    ExpandeDePara = Table.ExpandTableColumn(MesclaDePara, "DePara", {"Grupo_Padronizado"}, {"Nome_Padronizado"}),
    OrdemColunas = Table.SelectColumns(ExpandeDePara, {"Cod_Grupo", "Grupo_Transporte", "Nome_Padronizado", "Categoria", "Unidade"})
in
    OrdemColunas
