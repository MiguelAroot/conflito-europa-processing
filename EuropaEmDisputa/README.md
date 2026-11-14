# Europa em disputa

Protótipo de Algoritmos e Estruturas de Dados em Processing 4, modo Java. O cenário tem 30 países, 60 regiões e 76 ligações. Os atributos e os resultados representam regras do jogo.

## Abrir e jogar

1. Extraia a pasta `EuropaEmDisputa` inteira.
2. Abra `EuropaEmDisputa/EuropaEmDisputa.pde` no Processing 4, em modo Java, e clique em **Run**.
3. Escolha seu país em **Jogar como** antes da primeira rodada. A escolha vale até o fim. Clique no mapa ou use **Ver país** para consultar os demais.
4. Selecione uma região e programe uma ação. Investir custa 4 recursos. Recrutar custa 6 e reforçar custa 3. O custo de atacar aparece na ligação. Você pode trocar a ação até avançar a rodada.
5. Clique em **Próxima rodada** para aplicar sua escolha, resolver as ações dos adversários e contabilizar a renda. Com a ação **Poupar recursos**, o país recebe a renda da rodada e guarda o caixa disponível.

Use **Tela cheia** ou **F11** para alternar entre os modos. Em tela cheia, **Esc** também volta à janela, depois de fechar qualquer menu aberto. Na janela, você pode maximizar ou ajustar o tamanho pelas bordas. O jogo ajusta o mapa e os controles juntos e mantém a partida ao mudar de modo.

**Ligações e custos** lista os vizinhos da região selecionada. **Grafo completo** (tecla `G`) mostra todas as arestas. Em **Histórico**, as setas mudam a rodada consultada e o seletor **Ver país** troca o país mostrado. A aba **Evolução** mostra os pesos e o fitness. Quando sobra um vencedor, **Nova partida** libera uma nova escolha de país.

## Código

- `EuropaEmDisputa.pde`, `Mapa.pde` e `Tela.pde` carregam o mapa e controlam o desenho, os cliques e a navegação.
- `Grafo.java` guarda a adjacência em `HashMap<Integer, HashSet<Integer>>` e os custos em uma matriz esparsa de `HashMap`s. Cada aresta representa uma ligação do jogo, com custo inteiro.
- `Partida.java` calcula economia, movimentação de tropas, disputas, histórico e pontuação gulosa. Cada adversário escolhe a ação válida com maior pontuação. A previsão de ataque considera força, defesa, custo e baixas esperadas.
- `Evolucao.java` mantém dez estratégias por país, com pesos de expansão, proteção e economia. A cada duas rodadas, avalia cada candidato em uma cópia do jogo, por duas rodadas simuladas. O fitness recompensa PIB, caixa e territórios e penaliza baixas. A próxima população usa torneio de três, crossover uniforme, mutação e elitismo.

## Regras iniciais

Os cinco atributos começam somando 30 e vão de 0 a 20. O PIB combina mercado, comércio e territórios controlados. Mobilização e baixas reduzem a produção na rodada da disputa. As baixas também reduzem a produção na rodada seguinte. Um terço do PIB, arredondado para baixo, entra no caixa. Disputas suspendem temporariamente o comércio entre os dois países.

Uma invasão bem-sucedida elimina o defensor. O vencedor recebe todas as regiões que o defensor controlava e soma os cinco atributos dele aos seus, até 20 em cada. O mapa usa a cor e o nome do controlador atual. A consulta do país registra quem o derrotou. Se você for eliminado, pode acompanhar as rodadas até sobrar um vencedor.

Em um investimento alinhado à prioridade do governo, cada ponto de capacidade política acrescenta 4 pontos percentuais à chance de receber um ponto extra. O limite de 20 continua valendo. No jogo, o jogador define a própria prioridade e cada adversário usa o peso dominante de sua estratégia.

O mapa usa a geometria GISCO NUTS 2021 e Natural Earth para o contexto geográfico. © EuroGeographics pelos limites administrativos. Os pontos Norte e Sul e as ligações marítimas fazem parte da simulação.

- GISCO: https://gisco-services.ec.europa.eu/distribution/v2/nuts/nuts-2021-files.html
- Natural Earth: https://www.naturalearthdata.com/
