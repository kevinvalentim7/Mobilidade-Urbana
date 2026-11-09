// fnDataMes — constrói a data do 1º dia do mês (#date(Ano, Mês, 1)) ou devolve null se Ano/Mês forem inválidos (D1)
(ano as any, mes as any) as nullable date =>
let
    A = fnNumeroInteiro(ano),
    M = fnNumeroInteiro(mes),
    Data = if A <> null and M <> null and A >= 2020 and A <= 2030 and M >= 1 and M <= 12
           then #date(A, M, 1)
           else null
in
    try Data otherwise null
