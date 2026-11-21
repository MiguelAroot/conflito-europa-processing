import java.util.ArrayList;

public final class Historico {
    public static final class Resumo {
        private final int[] atributos;
        private final int pib, caixa, tropas, regioes, parceiros, renda, perdas;
        private final int derrotadoPor;
        private final String decisao, efeitos;
        private final double fitness;
        private final DecisaoGulosa.Escolha escolha;
        private final Evolucao.Estrategia estrategia;

        private Resumo(EstadoPartida.Pais p, int tropas, int regioes, Evolucao.Estrategia estrategia, double fitness) {
            atributos = p.atributos.clone();
            pib = p.pib;
            caixa = p.caixa;
            this.tropas = tropas;
            this.regioes = regioes;
            parceiros = p.parceiros;
            renda = p.renda;
            perdas = p.perdas;
            derrotadoPor = p.derrotadoPor;
            decisao = p.decisao;
            efeitos = p.efeitos;
            escolha = p.escolha;
            this.estrategia = estrategia;
            this.fitness = fitness;
        }

        public int atributo(int indice) { return atributos[indice]; }
        public int pib() { return pib; }
        public int caixa() { return caixa; }
        public int tropas() { return tropas; }
        public int regioes() { return regioes; }
        public int parceiros() { return parceiros; }
        public int renda() { return renda; }
        public int perdas() { return perdas; }
        public int derrotadoPor() { return derrotadoPor; }
        public String decisao() { return decisao; }
        public String efeitos() { return efeitos; }
        public double pontos() { return escolha == null ? Double.NaN : escolha.opcao.pontos; }
        public double melhorNota(Partida.Tipo tipo) {
            return escolha == null ? Double.NaN : escolha.melhorNota(tipo);
        }
        public Partida.Tipo tipoEscolhido() { return escolha == null ? null : escolha.opcao.acao.tipo(); }
        public boolean foiEmergencia() { return escolha != null && escolha.emergencia; }
        public Evolucao.Estrategia estrategia() { return estrategia; }
        public double fitness() { return fitness; }
    }

    public static final class Quadro {
        private final int rodada, geracao;
        private final Resumo[] paises;
        private final int[] donos, guarnicoes;
        private final double[] defesas;

        private Quadro(int rodada, int geracao, Resumo[] paises, int[] donos, int[] guarnicoes, double[] defesas) {
            this.rodada = rodada;
            this.geracao = geracao;
            this.paises = paises;
            this.donos = donos;
            this.guarnicoes = guarnicoes;
            this.defesas = defesas;
        }

        public int rodada() { return rodada; }
        public int geracao() { return geracao; }
        public Resumo pais(int indice) { return paises[indice]; }
        public int dono(int indice) { return donos[indice]; }
        public int guarnicao(int indice) { return guarnicoes[indice]; }
        public double defesa(int indice) { return defesas[indice]; }
    }

    private final ArrayList<Quadro> rodadas = new ArrayList<>();

    Quadro quadro(int rodada) { return rodadas.get(rodada); }

    void salvar(EstadoPartida estado, Evolucao evolucao) {
        int quantidade = estado.paises.length;
        int tamanho = estado.regioes.length;
        Resumo[] resumos = new Resumo[quantidade];
        for (int i = 0; i < quantidade; i++) {
            EstadoPartida.Pais p = estado.paises[i];
            resumos[i] = new Resumo(p, estado.contarTropas(i), estado.contarRegioes(i), evolucao.ativa(i), evolucao.melhorFitness(i));
        }
        int[] donos = new int[tamanho], tropas = new int[tamanho];
        double[] defesas = new double[tamanho];
        for (int i = 0; i < tamanho; i++) {
            donos[i] = estado.regioes[i].dono;
            tropas[i] = estado.regioes[i].tropas;
            defesas[i] = Combate.defesa(estado, i);
        }
        rodadas.add(new Quadro(estado.rodada, evolucao.geracao(), resumos, donos, tropas, defesas));
    }
}
