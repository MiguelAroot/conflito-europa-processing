import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public final class Evolucao {
    public static final int TAMANHO = 10;
    public static final String[] FOCOS = {"Expansão", "Proteção", "Economia"};

    public static final class Estrategia {
        private final double expansao, protecao, economia;

        public Estrategia(double expansao, double protecao, double economia) {
            double total = expansao + protecao + economia;
            this.expansao = expansao / total;
            this.protecao = protecao / total;
            this.economia = economia / total;
        }

        public double expansao() { return expansao; }
        public double protecao() { return protecao; }
        public double economia() { return economia; }

        public double gene(int indice) {
            switch (indice) {
                case 0: return expansao;
                case 1: return protecao;
                default: return economia;
            }
        }

        public int foco() {
            if (expansao >= protecao && expansao >= economia) return 0;
            return protecao >= economia ? 1 : 2;
        }

        public double pesoMaior() { return gene(foco()); }

        public static Estrategia comFoco(int foco) {
            return new Estrategia(foco == 0 ? 0.60 : 0.20, foco == 1 ? 0.60 : 0.20, foco == 2 ? 0.60 : 0.20);
        }
    }

    private final Random sorte;
    private final List<List<Estrategia>> populacoes = new ArrayList<>();
    private final Estrategia[] ativas;
    private final double[] fitness;
    private int geracao = 1;

    public Evolucao(int quantidadePaises, Random sorte) {
        this.sorte = sorte;
        ativas = new Estrategia[quantidadePaises];
        fitness = new double[quantidadePaises];
        for (int pais = 0; pais < quantidadePaises; pais++) {
            List<Estrategia> populacao = new ArrayList<>(TAMANHO);
            for (int i = 0; i < TAMANHO; i++) {
                populacao.add(new Estrategia(0.08 + sorte.nextDouble(), 0.08 + sorte.nextDouble(), 0.08 + sorte.nextDouble()));
            }
            populacoes.add(populacao);
            ativas[pais] = populacao.get(0);
            fitness[pais] = Double.NaN;
        }
    }

    public int geracao() { return geracao; }
    public Estrategia ativa(int pais) { return ativas[pais]; }
    public Estrategia[] ativas() { return ativas.clone(); }
    public double melhorFitness(int pais) { return fitness[pais]; }

    public void avancar(Partida partida, EstadoPartida estado) {
        // Mesmos adversários no teste
        Estrategia[] referencia = ativas();
        for (int pais = 0; pais < ativas.length; pais++) {
            if (!partida.ativo(estado, pais)) continue;
            long semente = sorte.nextLong();
            List<Estrategia> atual = populacoes.get(pais);
            double[] notas = new double[TAMANHO];
            int elite = 0;
            for (int i = 0; i < TAMANHO; i++) {
                notas[i] = partida.fitness(estado, referencia, pais, atual.get(i), semente);
                if (notas[i] > notas[elite]) elite = i;
            }

            List<Estrategia> nova = new ArrayList<>(TAMANHO);
            nova.add(atual.get(elite));
            Estrategia melhor = nova.get(0);
            double melhorNota = notas[elite];
            while (nova.size() < TAMANHO) {
                Estrategia a = atual.get(torneio(notas));
                Estrategia b = atual.get(torneio(notas));
                Estrategia filha = crossover(a, b);
                nova.add(filha);
                double nota = partida.fitness(estado, referencia, pais, filha, semente);
                if (nota > melhorNota) {
                    melhor = filha;
                    melhorNota = nota;
                }
            }
            populacoes.set(pais, nova);
            ativas[pais] = melhor;
            fitness[pais] = melhorNota;
        }
        geracao++;
    }

    private int torneio(double[] notas) {
        int a = sorte.nextInt(notas.length);
        int b;
        do { b = sorte.nextInt(notas.length); } while (b == a);
        int c;
        do { c = sorte.nextInt(notas.length); } while (c == a || c == b);
        int melhor = notas[b] > notas[a] ? b : a;
        return notas[c] > notas[melhor] ? c : melhor;
    }

    private Estrategia crossover(Estrategia a, Estrategia b) {
        return new Estrategia(mutar((sorte.nextBoolean() ? a : b).expansao()),
            mutar((sorte.nextBoolean() ? a : b).protecao()),
            mutar((sorte.nextBoolean() ? a : b).economia()));
    }

    private double mutar(double peso) {
        if (sorte.nextDouble() < 0.18) peso += (sorte.nextDouble() - 0.5) * 0.44;
        return Math.max(0.04, peso);
    }
}
