Protótipo de Algoritmos e Estruturas de Dados em Processing, modo Java. O cenário tem 30 países, 60 regiões e 76 ligações. Os atributos e os resultados representam regras do jogo.

## Abrir e jogar

1. Extraia a pasta `EuropaEmDisputa` inteira.
2. Abra `EuropaEmDisputa/EuropaEmDisputa.pde` no Processing, em modo Java, e clique em **Run**.
3. Escolha seu país em **Jogar como** antes da primeira rodada. A escolha vale até o fim. Clique no mapa ou use **Ver país** para consultar os demais.
4. Selecione uma região e programe uma ação. Investir custa 4 recursos. Recrutar custa 6 e reforçar custa 3. O custo de atacar aparece na ligação. Você pode trocar a ação até avançar a rodada.
5. Clique em **Próxima rodada** para aplicar sua escolha, resolver as ações dos adversários e contabilizar a renda. Com a ação **Poupar recursos**, o país recebe a renda da rodada e guarda o caixa disponível.

Use **Tela cheia** ou **F11** para alternar entre os modos. Em tela cheia, **Esc** também volta à janela, depois de fechar qualquer menu aberto. Na janela, você pode maximizar ou ajustar o tamanho pelas bordas. O jogo ajusta o mapa e os controles juntos e mantém a partida ao mudar de modo.

**Vizinhos e custos** lista os vizinhos da região selecionada. **Grafo** (tecla `G`) mostra todas as arestas. Em **Histórico**, as setas mudam a rodada consultada e **Ver país** troca o país mostrado. A aba **Evolução** compara os pesos e o fitness com os da geração anterior. Quando sobra um vencedor, **Nova partida** libera uma nova escolha de país.

No histórico de um adversário, **Ver notas** mostra as notas de investir, recrutar, reforçar, atacar e poupar. A opção escolhida fica marcada. Cada nota vem das ações disponíveis na hora da decisão. Em uma situação sem progresso, o programa pode priorizar retomar a disputa, e isso aparece na consulta.

## Consultar a menor rota

1. Abra **Rotas** e selecione uma região pelo mapa ou pelo menu de países. Use **Norte** ou **Sul** para ajustar a seleção.
2. Clique em **Fixar região como origem** e selecione outra região como destino.
3. A rota fica destacada no mapa. O painel mostra os trechos, seus custos e o total.

O Dijkstra usa as ligações do mapa, incluindo as marítimas. A consulta pode atravessar regiões de qualquer país. Ataques continuam usando uma ligação direta.

## Código

- `EuropaEmDisputa.pde`, `Mapa.pde` e `Tela.pde` carregam o mapa e controlam o desenho, os cliques e a navegação.
- `Grafo.java` guarda a adjacência em `HashMap<Integer, HashSet<Integer>>` e os custos em uma matriz esparsa de `HashMap`s. O Dijkstra usa vetores de distâncias, anteriores e visitados para encontrar a rota de menor custo.
- `Partida.java` coordena as rodadas, as ações e a avaliação do fitness.
- `EstadoPartida.java` guarda países, tropas e regiões e permite copiar o cenário para os testes do algoritmo genético.
- `Economia.java` calcula PIB, renda, comércio e o bônus político dos investimentos.
- `Combate.java` calcula as previsões, resolve as batalhas e transfere os territórios conquistados.
- `DecisaoGulosa.java` compara as ações disponíveis e guarda as notas da escolha.
- `Historico.java` guarda os resultados e as notas de cada rodada sem alterar registros anteriores.
- `Evolucao.java` mantém dez estratégias por país, com pesos de expansão, proteção e economia. A cada duas rodadas, avalia cada candidato em uma cópia do jogo, por duas rodadas simuladas. O fitness recompensa PIB, caixa e territórios e penaliza baixas. A próxima população usa torneio de três, crossover uniforme, mutação e elitismo.

## Regras iniciais

Os cinco atributos começam somando 30 e vão de 0 a 20. O PIB combina mercado, comércio e territórios controlados. Mobilização e baixas reduzem a produção na rodada da disputa. As baixas também reduzem a produção na rodada seguinte. Um terço do PIB, arredondado para baixo, entra no caixa. Disputas suspendem temporariamente o comércio entre os dois países.

Uma invasão bem-sucedida elimina o defensor. O vencedor recebe todas as regiões que o defensor controlava e soma os cinco atributos dele aos seus, até 20 em cada. O mapa usa a cor e o nome do controlador atual. A consulta do país registra quem o derrotou. Se você for eliminado, pode acompanhar as rodadas até sobrar um vencedor.

Em um investimento alinhado à prioridade do governo, cada ponto de capacidade política acrescenta 4 pontos percentuais à chance de receber um ponto extra. O limite de 20 continua valendo. No jogo, o jogador define a própria prioridade e cada adversário usa o peso dominante de sua estratégia.

O mapa usa a geometria GISCO NUTS 2021 e Natural Earth para o contexto geográfico. © EuroGeographics pelos limites administrativos. Os pontos Norte e Sul e as ligações marítimas fazem parte da simulação.

- GISCO: https://gisco-services.ec.europa.eu/distribution/v2/nuts/nuts-2021-files.html
- Natural Earth: https://www.naturalearthdata.com/
