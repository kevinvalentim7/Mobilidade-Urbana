// fnNumeroInteiro — replica a limpeza numérica da Etapa 1 (remove pontos de milhar, espaços/CHAR(160) e converte para inteiro pt-BR)
(valor as any) as nullable number =>
let
    Resultado =
        if valor = null then null
        else if valor is number then Int64.From(valor)
        else
            let
                Limpo = Text.Replace(Text.Replace(Text.Trim(Text.From(valor)), ".", ""), Character.FromNumber(160), "")
            in
                Int64.From(Number.FromText(Limpo, "pt-BR"))
in
    try Resultado otherwise null
