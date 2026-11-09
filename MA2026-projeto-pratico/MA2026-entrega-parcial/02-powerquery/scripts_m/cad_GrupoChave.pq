// cad_GrupoChave — chave em MAIÚSCULAS para mesclar pelo nome do cabeçalho da SPTrans
let
    ComChave = Table.AddColumn(dGrupo, "Chave_Grupo", each Text.Upper(Text.Trim([Grupo_Transporte])), type text),
    Selecionadas = Table.SelectColumns(ComChave, {"Chave_Grupo", "Cod_Grupo", "Nome_Padronizado", "Categoria"})
in
    Selecionadas
