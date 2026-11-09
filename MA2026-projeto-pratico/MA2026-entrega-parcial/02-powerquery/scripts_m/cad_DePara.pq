// cad_DePara — tabela Tab_DePara da Etapa 1 (Código -> Nome padronizado)
let
    Fonte = cad_Etapa1{[Item = "Tab_DePara", Kind = "Table"]}[Data],
    Renomeada = Table.RenameColumns(Fonte, {{"Código", "Cod_Grupo"}, {"Nome padronizado", "Grupo_Padronizado"}}),
    Tipos = Table.TransformColumnTypes(Renomeada, {{"Cod_Grupo", type text}, {"Grupo_Padronizado", type text}}),
    ComChave = Table.AddColumn(Tipos, "Chave_Codigo", each Text.Upper(Text.Trim([Cod_Grupo])), type text)
in
    ComChave
