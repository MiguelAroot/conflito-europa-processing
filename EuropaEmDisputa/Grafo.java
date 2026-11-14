import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public final class Grafo {
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
}
