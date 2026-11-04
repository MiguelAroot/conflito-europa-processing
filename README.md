# Conflito de Fronteiras — Europa

Protótipo inicial de um jogo de estratégia territorial feito em **Processing (modo Java)** para a disciplina de Algoritmos e Estruturas de Dados.

## Como executar

1. Instale o [Processing](https://processing.org/download).
2. Abra o arquivo `Conflito_Europa/Conflito_Europa.pde` no Processing, no modo Java.
3. Pressione **Executar** (▶).

## Controles

- Clique em um país e depois em um país vizinho para tentar conquistar seu território.
- Pressione **C** para demonstrar um crossover: a Alemanha recebe o ataque da Inglaterra e a defesa da Espanha.

## Países

- Inglaterra
- França
- Espanha
- Alemanha

## Estruturas e conceitos

- **ArrayList:** armazena a lista de países.
- **HashMap:** associa nomes aos países e armazena conexões.
- **HashSet:** mantém os vizinhos de cada país sem repetição.
- **Grafo:** representa países e ligações entre eles.
- **Matriz esparsa:** registra somente os pesos das conexões existentes, usando um mapa de pares de índices.
- **Crossover:** demonstra a recombinação de dois atributos. Ainda não há um algoritmo genético completo.

## Estado atual

Esta é somente a primeira etapa. As disputas usam valores de ataque e defesa com aleatoriedade, e as conquistas alteram a cor dos territórios.

## Próximas etapas

- Melhorar a representação visual dos territórios.
- Implementar turnos e recursos.
- Criar uma população de estratégias com seleção, fitness, crossover, mutação e gerações.
- Adicionar países controlados pelo computador e condições de vitória.

O mapa é esquemático e simplificado; a ligação Inglaterra–França é representada como passagem marítima.
