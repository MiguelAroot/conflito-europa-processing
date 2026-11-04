# Conflito de Fronteiras — Europa

Protótipo de jogo de estratégia territorial em **Processing (modo Java)** para Algoritmos e Estruturas de Dados.

Não usa bibliotecas extras nem imagens externas.

## Ideia do jogo

Inglaterra, França, Espanha e Alemanha controlam duas regiões cada. Cada país administra recursos e uma estratégia com três atributos: expansão, proteção e economia. Conexões entre regiões determinam onde podem ocorrer disputas abstratas. O jogador controla um país e os outros realizam ações automáticas a cada turno.

O desenho é um **mapa esquemático**, não uma representação cartográfica exata.

## Controles

| Comando | Ação |
| --- | --- |
| Clique em uma região sua e depois em uma região vizinha de outro país | Tentar conquistar uma região (3 recursos, 1 ação) |
| `R` | Reforçar a região selecionada (2 recursos, 1 ação) |
| `ESPAÇO` | Avançar o turno (recursos e ações dos rivais) |
| `G` | Evoluir mais uma geração de estratégias |
| `F` | Mostrar ou esconder o grafo e os pesos das conexões |
| `1`, `2`, `3`, `4` | Mudar o país controlado |
| `N` | Reiniciar o jogo |

Os botões no painel também permitem avançar turno, reforçar e evoluir.

## Conteúdos da disciplina

- **Lista (`ArrayList`):** armazena as oito regiões e as populações de estratégias.
- **Dicionários (`HashMap`):** encontram os países por nome e organizam as estruturas de conexões.
- **Conjuntos (`HashSet`):** guardam regiões vizinhas sem repetição.
- **Grafo:** oito vértices (regiões), nove ligações, usando lista de adjacência.
- **Matriz esparsa:** `HashMap<Integer, HashMap<Integer, Integer>>` armazena somente os custos das ligações existentes.
- **Computação evolucionária:** cada país mantém dez genomas, com expansão, proteção e economia. Uma função fitness avalia os genomas conforme o estado do jogo. A geração seguinte preserva o melhor, usa seleção por torneio, crossover e mutação aleatória. O processo também acontece automaticamente a cada dois turnos.

## O que já funciona

- Mapa com oito regiões coloridas pelo país que as controla.
- Conexões terrestres e uma passagem marítima Inglaterra–França.
- Disputas com custos, resultados variáveis e mudanças de controle.
- Acúmulo de recursos, reforço e duas ações por turno.
- Três países com decisões automáticas.
- Estratégias evolutivas, gráfico do fitness e contador de gerações.

## O que falta

- Cartografia mais precisa e animações.
- Uma avaliação de fitness com testes mais elaborados.
- Balanceamento das regras e adversários mais interessantes.
- Tela inicial, tutorial e condições adicionais de vitória.

Este é um protótipo didático, com disputas abstratas, e não um simulador militar realista.
