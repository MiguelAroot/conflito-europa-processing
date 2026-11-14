# Europa em disputa

Jogo de estratégia territorial feito em **Processing 4**, no modo Java, para a disciplina de **Algoritmos e Estruturas de Dados**. O mapa tem 30 países, 60 regiões e 76 ligações.

## Ideia do jogo

Você escolhe um país antes da primeira rodada e joga com ele até o fim. A cada rodada, pode investir, recrutar tropas, reforçar uma região ou tentar invadir um vizinho. Os outros países decidem suas ações automaticamente.

O mercado, o comércio e as regiões controladas contribuem para o PIB. Parte do PIB vira caixa para financiar as próximas ações. As baixas reduzem a produção, então mesmo uma vitória pode enfraquecer a economia nas rodadas seguintes.

Uma invasão bem-sucedida elimina o país defensor. O vencedor assume as regiões que ele controlava e soma os atributos dele aos seus, até o limite de **20 pontos por atributo**. O mapa passa a mostrar a cor e o nome do controlador atual. A partida termina quando um único país domina todas as regiões.

## Como executar

1. Baixe e extraia o repositório inteiro.
2. Abra [`EuropaEmDisputa/EuropaEmDisputa.pde`](EuropaEmDisputa/EuropaEmDisputa.pde) no Processing 4, em modo Java.
3. Clique em **Run** e escolha seu país em **Jogar como**.

## Controles

| Controle | O que faz |
| --- | --- |
| Clique no mapa ou use **Ver país** | Consulta os atributos e a situação de um país. |
| **Norte** e **Sul** | Seleciona uma das duas regiões do país em exibição. |
| **Ligações e custos** | Mostra os vizinhos da região e o custo de cada ligação. |
| **Próxima rodada** | Executa a ação programada e avança a partida inteira. |
| **Histórico** | Mostra a decisão e os resultados do país escolhido em cada rodada. |
| **Evolução** | Mostra os pesos da estratégia e a nota de fitness. |
| **Grafo completo** ou **G** | Mostra todas as conexões do mapa. |
| **F11** | Alterna entre janela e tela cheia. |

## Conteúdos da disciplina

- **Grafo ponderado** — As regiões são vértices e as conexões são arestas com custo. Um `HashMap` aponta para o `HashSet` de vizinhos de cada região. Uma matriz esparsa de `HashMap`s guarda só os custos das ligações existentes.
- **Decisão gulosa** — Cada adversário pontua as ações disponíveis. Para atacar, considera a chance de vitória, o custo da ligação e as perdas estimadas. Com base nisso e na prioridade do país, decide se vale avançar, investir ou se defender.
- **Algoritmo genético** — Cada país começa com 10 estratégias, com pesos para expansão, proteção e economia. A cada duas rodadas, os candidatos são avaliados em cópias da partida. A nota de fitness considera mudanças no PIB, no caixa, nas tropas e nos territórios, além das baixas. A geração seguinte usa seleção por torneio de três, crossover uniforme, mutação e elitismo.

## O que já funciona

- Mapa colorido baseado em cartografia real, com seleção de países e visualização do grafo.
- Economia por rodada, investimentos, defesa, recrutamento e disputas territoriais.
- Consulta individual dos atributos, das decisões e dos resultados de cada país.
- Conquista de países inteiros, eliminação e identificação do vencedor.

O balanceamento ainda pode ser refinado, especialmente os custos das ações e o peso das baixas no PIB.

[Guia com as regras e a organização dos arquivos](EuropaEmDisputa/README.md)
