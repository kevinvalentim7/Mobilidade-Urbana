# Documentação das medidas DAX — Projeto de Mobilidade Urbana

**Modelo:** `Mobilidade_02_PowerQuery.xlsx`  
**Atualização:** 09/11/2026  
**Ambiente:** Excel / Power Pivot

Este documento reúne as medidas DAX trabalhadas durante a montagem do modelo de dados. As medidas estão organizadas por tabela fato e incluem finalidade, dependências e formato recomendado.

> **Observação:** os nomes abaixo seguem as denominações usadas nas fórmulas desta documentação. Caso algum nome tenha sido alterado no Power Pivot, ajuste também as referências entre medidas.

---

## 1. `fPassageirosGrupo`

Tabela de granularidade mensal por grupo. As medidas abaixo permitem analisar volume, comparação entre meses e evolução acumulada.

### 1.1. Total de Passageiros

**Finalidade:** somar a quantidade de passageiros respeitando os filtros de período, grupo e demais dimensões.

```dax
=SUM(fPassageirosGrupo[Passageiros])
```

**Formato recomendado:** número inteiro com separador de milhares.

### 1.2. Passageiros Mês Anterior

**Finalidade:** recuperar o total do mês anterior ao período selecionado. Retorna vazio quando não há total no mês atual, evitando exibir uma comparação sem valor atual.

```dax
=IF(
    ISBLANK([Total de Passageiros]),
    BLANK(),
    CALCULATE(
        [Total de Passageiros],
        PREVIOUSMONTH(dCalendario[Date])
    )
)
```

**Dependências:** `[Total de Passageiros]` e `dCalendario[Date]`.  
**Formato recomendado:** número inteiro.

### 1.3. Variação Mensal (%)

**Finalidade:** calcular a variação percentual entre o total do mês atual e o do mês anterior. Retorna vazio quando um dos períodos não possui valor, evitando percentuais enganosos.

```dax
=IF(
    OR(
        ISBLANK([Total de Passageiros]),
        ISBLANK([Passageiros Mês Anterior])
    ),
    BLANK(),
    DIVIDE(
        [Total de Passageiros] - [Passageiros Mês Anterior],
        [Passageiros Mês Anterior]
    )
)
```

**Dependências:** `[Total de Passageiros]` e `[Passageiros Mês Anterior]`.  
**Formato recomendado:** porcentagem.

### 1.4. Média Mensal de Passageiros

**Finalidade:** calcular a média dos totais mensais no contexto de filtros atual. `VALUES` fornece os períodos distintos e `AVERAGEX` calcula a média dos totais de cada período.

```dax
=AVERAGEX(
    VALUES(fPassageirosGrupo[Chave_Periodo]),
    CALCULATE([Total de Passageiros])
)
```

**Dependências:** `[Total de Passageiros]` e `fPassageirosGrupo[Chave_Periodo]`.  
**Formato recomendado:** número inteiro ou decimal, conforme o nível de precisão desejado.

### 1.5. Passageiros Acumulados no Ano

**Finalidade:** calcular o total acumulado desde o início do ano até a data ou período do contexto atual. Retorna vazio quando não existe total no período atual.

```dax
=IF(
    ISBLANK([Total de Passageiros]),
    BLANK(),
    TOTALYTD(
        [Total de Passageiros],
        dCalendario[Date]
    )
)
```

**Dependências:** `[Total de Passageiros]` e `dCalendario[Date]`.  
**Formato recomendado:** número inteiro com separador de milhares.

---

## 2. `fTotaisAnuais`

Tabela de granularidade anual por grupo, utilizada para confrontar o total anual publicado com a soma dos meses tratados.

### 2.1. Total Anual Publicado

**Finalidade:** somar o total anual informado na fonte, respeitando os filtros de ano e grupo.

```dax
=SUM(fTotaisAnuais[Total_Anual_Publicado])
```

**Formato recomendado:** número inteiro com separador de milhares.

### 2.2. Total dos Meses Tratados

**Finalidade:** somar os valores mensais tratados consolidados na tabela anual.

```dax
=SUM(fTotaisAnuais[Soma_Meses_Tratados])
```

**Formato recomendado:** número inteiro com separador de milhares.

### 2.3. Diferença Anual Registrada

**Finalidade:** apresentar a diferença registrada entre o total anual publicado e a soma mensal tratada, conforme o campo de auditoria da tabela.

```dax
=SUM(fTotaisAnuais[Diferenca_Anual])
```

**Formato recomendado:** número inteiro com separador de milhares. Valores negativos e positivos devem ser preservados.

### 2.4. Divergência Anual (%)

**Finalidade:** expressar a diferença anual em relação ao total publicado, permitindo comparar a dimensão relativa das divergências entre grupos e anos.

```dax
=DIVIDE(
    [Diferença Anual Registrada],
    [Total Anual Publicado]
)
```

**Dependências:** `[Diferença Anual Registrada]` e `[Total Anual Publicado]`.  
**Formato recomendado:** porcentagem.

---

## 3. `fMobilidade`

Tabela de granularidade mensal com total publicado, total calculado e status de conferência. As medidas avaliam diferenças e frequência de meses divergentes.

### 3.1. Medida - Total Publicado

**Finalidade:** somar os totais publicados no contexto de período atual.

```dax
=SUM(fMobilidade[Total publicado])
```

**Formato recomendado:** número inteiro com separador de milhares.

### 3.2. Medida - Total Calculado

**Finalidade:** somar os totais calculados a partir dos grupos no contexto de período atual.

```dax
=SUM(fMobilidade[Total_Calculado])
```

**Formato recomendado:** número inteiro com separador de milhares.

### 3.3. Medida - Diferença entre Totais

**Finalidade:** calcular a diferença entre o total calculado e o total publicado. Resultado positivo indica total calculado maior; resultado negativo indica total calculado menor.

```dax
=[Medida - Total Calculado] - [Medida - Total Publicado]
```

**Dependências:** `[Medida - Total Calculado]` e `[Medida - Total Publicado]`.  
**Formato recomendado:** número inteiro com separador de milhares.

### 3.4. Medida - Divergência Percentual

**Finalidade:** expressar a diferença entre os totais como proporção do total publicado.

```dax
=DIVIDE(
    [Medida - Diferença entre Totais],
    [Medida - Total Publicado]
)
```

**Dependências:** `[Medida - Diferença entre Totais]` e `[Medida - Total Publicado]`.  
**Formato recomendado:** porcentagem.

### 3.5. Medida - Meses Divergentes

**Finalidade:** contar os meses distintos classificados como `Divergente` no campo `Status_Total`, respeitando os filtros aplicados.

```dax
=CALCULATE(
    DISTINCTCOUNT(fMobilidade[Data_Trat]),
    fMobilidade[Status_Total] = "Divergente"
)
```

**Formato recomendado:** número inteiro.

### 3.6. Medida - Frequência de Meses Divergentes (%)

**Finalidade:** calcular a proporção dos meses divergentes em relação ao número de meses presentes no contexto atual.

```dax
=DIVIDE(
    [Medida - Meses Divergentes],
    DISTINCTCOUNT(fMobilidade[Data_Trat])
)
```

**Dependências:** `[Medida - Meses Divergentes]` e `fMobilidade[Data_Trat]`.  
**Formato recomendado:** porcentagem.

---

## 4. Resumo das medidas

| Tabela | Medida | Tipo de resultado |
|---|---|---|
| `fPassageirosGrupo` | Total de Passageiros | Quantidade |
| `fPassageirosGrupo` | Passageiros Mês Anterior | Quantidade |
| `fPassageirosGrupo` | Variação Mensal (%) | Percentual |
| `fPassageirosGrupo` | Média Mensal de Passageiros | Média |
| `fPassageirosGrupo` | Passageiros Acumulados no Ano | Acumulado |
| `fTotaisAnuais` | Total Anual Publicado | Quantidade |
| `fTotaisAnuais` | Total dos Meses Tratados | Quantidade |
| `fTotaisAnuais` | Diferença Anual Registrada | Diferença |
| `fTotaisAnuais` | Divergência Anual (%) | Percentual |
| `fMobilidade` | Medida - Total Publicado | Quantidade |
| `fMobilidade` | Medida - Total Calculado | Quantidade |
| `fMobilidade` | Medida - Diferença entre Totais | Diferença |
| `fMobilidade` | Medida - Divergência Percentual | Percentual |
| `fMobilidade` | Medida - Meses Divergentes | Contagem |
| `fMobilidade` | Medida - Frequência de Meses Divergentes (%) | Percentual |

---

## 5. Observações sobre o modelo e as validações

- `dCalendario` filtra `fPassageirosGrupo` pela data mensal e `fMobilidade` por `Data_Trat`.
- `dGrupo` filtra `fPassageirosGrupo` e `fTotaisAnuais` pelo código do grupo.
- `fTotaisAnuais` é anual e utiliza `Ano_Inicio` (1º de janeiro de cada ano) para o relacionamento com `dCalendario[Date]`. Portanto, seus valores devem ser analisados em contexto anual; em visuais mensais, o valor anual pode aparecer apenas no contexto de janeiro.
- `fMobilidade` contém totais de três grupos em colunas separadas. Seu campo `Cod_Grupo_Referencia` não deve ser usado como se cada linha representasse exclusivamente um grupo: ele contém uma referência única (`DIS`) e não descreve a granularidade dos três totais da linha.
- As medidas percentuais usam `DIVIDE`, que evita erro de divisão por zero e retorna vazio quando o denominador não permite o cálculo.
- Em `fMobilidade`, os meses de julho e setembro de 2026 foram identificados como divergentes durante a conferência realizada no projeto.
- A medida `Passageiros Acumulados Ano Anterior`, baseada em `SAMEPERIODLASTYEAR`, foi discutida, mas não foi incluída como medida concluída neste registro.

---

## 6. Itens não incluídos

Não foram documentadas medidas de participação por grupo porque o modelo já possui a coluna `Participacao_Mes`, e a fórmula de uma eventual medida independente não ficou estabelecida neste registro. Também não foi incluída uma medida de comparação acumulada com o ano anterior, pois sua lógica de tratamento de períodos sem dados ainda não foi finalizada.
