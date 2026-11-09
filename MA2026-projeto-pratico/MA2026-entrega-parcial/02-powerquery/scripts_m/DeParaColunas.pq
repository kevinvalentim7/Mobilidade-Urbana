// DeParaColunas — resolve o defeito D10 (nomes de cabeçalhos divergentes entre arquivos anuais)
let
    Tabela = #table(type table [Nome_Origem = text, Nome_Alvo = text], {
        {"Ano_Ref",              "Ano"},
        {"Mes",                  "Mês"},
        {"Mes_Ref",              "Mês"},
        {"Grp_Estrutural",       "Grupo Estrutural"},
        {"Estrutural",           "Grupo Estrutural"},
        {"Grp_Articulacao",      "Grupo Local de Articulação Regional"},
        {"Articulacao Regional", "Grupo Local de Articulação Regional"},
        {"Grp_Distribuicao",     "Grupo Local de Distribuição"},
        {"Distribuicao",         "Grupo Local de Distribuição"},
        {"Total_Publicado",      "Total publicado"},
        {"Total SPTrans",        "Total publicado"}
    })
in
    Tabela
