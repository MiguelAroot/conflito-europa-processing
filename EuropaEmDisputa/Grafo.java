import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public final class Grafo {
    public static final class Rota {
        private final int[] regioes;
        private final long custo;

        Rota(int[] regioes, long custo) {
            this.regioes = regioes;
            this.custo = custo;
        }

        public int tamanho() { return regioes.length; }
        public int regiao(int indice) { return regioes[indice]; }
        public long custo() { return custo; }
    }

    public static final class Aresta {
        private final int a, b, custo;
        private final boolean maritima;

        Aresta(int a, int b, int custo, boolean maritima) {
            this.a = a;
            this.b = b;
            this.custo = custo;
            this.maritima = maritima;
        }

        public int a() { return a; }
        public int b() { return b; }
        public int custo() { return custo; }
        public boolean maritima() { return maritima; }
    }

    private final HashMap<Integer, HashSet<Integer>> adjacencias = new HashMap<>();
    private final HashMap<Integer, HashMap<Integer, Integer>> custos = new HashMap<>();
    private final ArrayList<Aresta> arestas = new ArrayList<>();
    public final int tamanho;

    public Grafo(int tamanho) {
        this.tamanho = tamanho;
        for (int i = 0; i < tamanho; i++) {
            adjacencias.put(i, new HashSet<>());
            custos.put(i, new HashMap<>());
        }
    }

    public void conectar(int a, int b, int custo, boolean maritima) {
        if (!adjacencias.containsKey(a) || !adjacencias.containsKey(b) || a == b || custo <= 0) {
            throw new IllegalArgumentException("Ligação inválida no mapa");
        }
        if (!adjacencias.get(a).add(b)) {
            throw new IllegalArgumentException("Ligação repetida no mapa");
        }
        adjacencias.get(b).add(a);
        custos.get(a).put(b, custo);
        custos.get(b).put(a, custo);
        arestas.add(new Aresta(a, b, custo, maritima));
    }

    public Set<Integer> vizinhos(int regiao) {
        return Collections.unmodifiableSet(adjacencias.get(regiao));
    }

    public int custo(int a, int b) {
        return custos.get(a).getOrDefault(b, -1);
    }

    public List<Aresta> arestas() {
        return Collections.unmodifiableList(arestas);
    }

    public Rota menorRota(int origem, int destino) {
        if (!adjacencias.containsKey(origem) || !adjacencias.containsKey(destino)) {
            throw new IllegalArgumentException("Origem ou destino inválido");
        }
        long[] distancias = new long[tamanho];
        int[] anteriores = new int[tamanho];
        boolean[] visitados = new boolean[tamanho];
        Arrays.fill(distancias, Long.MAX_VALUE);
        Arrays.fill(anteriores, -1);
        distancias[origem] = 0;

        // Dijkstra
        for (int i = 0; i < tamanho; i++) {
            int atual = -1;
            long menor = Long.MAX_VALUE;
            for (int regiao = 0; regiao < tamanho; regiao++) {
                if (!visitados[regiao] && distancias[regiao] < menor) {
                    atual = regiao;
                    menor = distancias[regiao];
                }
            }
            if (atual == -1 || atual == destino) break;
            visitados[atual] = true;
            for (int vizinho : adjacencias.get(atual)) {
                long novoCusto = menor + custo(atual, vizinho);
                if (!visitados[vizinho] && novoCusto < distancias[vizinho]) {
                    distancias[vizinho] = novoCusto;
                    anteriores[vizinho] = atual;
                }
            }
        }

        if (distancias[destino] == Long.MAX_VALUE) return new Rota(new int[0], -1);
        ArrayList<Integer> caminho = new ArrayList<>();
        for (int regiao = destino; regiao != -1; regiao = anteriores[regiao]) caminho.add(regiao);
        int[] resultado = new int[caminho.size()];
        for (int i = 0; i < resultado.length; i++) resultado[i] = caminho.get(resultado.length - 1 - i);
        return new Rota(resultado, distancias[destino]);
    }
}
