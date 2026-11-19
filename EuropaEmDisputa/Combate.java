import java.util.Random;

public final class Partida {
    public static final int MERCADO = 0, FORCAS = 1, COMERCIO = 2, INFRA = 3, POLITICA = 4;
    public static final int MAX_ATRIBUTO = 20;
    public static final String[] ATRIBUTOS = {
        "Mercado", "Forças armadas", "Comércio", "Infraestrutura", "Capacidade política"
    };

    public enum Tipo { PASSAR, INVESTIR, RECRUTAR, REFORCAR, ATACAR }
    public static final class Acao {
        private final Tipo tipo;
        private final int origem, alvo;

        private Acao(Tipo tipo, int origem, int alvo) {
            this.tipo = tipo;
            this.origem = origem;
            this.alvo = alvo;
        }

        public Tipo tipo() { return tipo; }
        public int origem() { return origem; }
        public int alvo() { return alvo; }
        public static Acao passar() { return new Acao(Tipo.PASSAR, -1, -1); }
        public static Acao investir(int atributo) { return new Acao(Tipo.INVESTIR, -1, atributo); }
        public static Acao recrutar(int regiao) { return new Acao(Tipo.RECRUTAR, -1, regiao); }
        public static Acao reforcar(int regiao) { return new Acao(Tipo.REFORCAR, -1, regiao); }
        public static Acao atacar(int origem, int alvo) { return new Acao(Tipo.ATACAR, origem, alvo); }
    }
    public static final class DadosPais {
        private final String codigo, nome;
        private final int[] atributos;

        public DadosPais(String codigo, String nome, int[] atributos) {
            this.codigo = codigo;
            this.nome = nome;
            this.atributos = atributos.clone();
        }

        public String codigo() { return codigo; }
        public String nome() { return nome; }
        public int atributo(int indice) { return atributos[indice]; }
    }

    private final DadosPais[] dados;
    public final Grafo grafo;
    public final int jogador;
    private final EstadoPartida estado;
    private final Evolucao evolucao;
    private final Random sorte;
    private final Historico historico = new Historico();
    private final DecisaoGulosa guloso = new DecisaoGulosa(this);

    public Partida(DadosPais[] dados, Grafo grafo, int jogador, long semente) {
        this.dados = dados.clone();
        this.grafo = grafo;
        this.jogador = jogador;
        sorte = new Random(semente);
        estado = new EstadoPartida(dados.length, grafo.tamanho);
        for (int i = 0; i < dados.length; i++) estado.paises[i] = new EstadoPartida.Pais(dados[i].atributos);
        for (int i = 0; i < grafo.tamanho; i++) estado.regioes[i] = new EstadoPartida.Regiao(i / 2, 4 + sorte.nextInt(8));
        evolucao = new Evolucao(dados.length, new Random(semente ^ 0x5DEECE66DL));
        Economia.atualizar(estado, grafo, false);
        historico.salvar(estado, evolucao);
    }

    public int rodada() { return estado.rodada; }
    public int geracao() { return evolucao.geracao(); }
    public Historico.Quadro quadro(int rodada) { return historico.quadro(rodada); }
    String nomePais(int id) { return dados[id].nome(); }
    public String nomeRegiao(int regiao) { return dados[regiao / 2].nome() + " · " + (regiao % 2 == 0 ? "Norte" : "Sul"); }
    public int dono(int regiao) { return estado.regioes[regiao].dono; }

    public int vencedor() {
        int dono = estado.regioes[0].dono;
        for (EstadoPartida.Regiao regiao : estado.regioes) if (regiao.dono != dono) return -1;
        return dono;
    }
    public int custo(Acao acao) {
        switch (acao.tipo()) {
            case PASSAR: return 0;
            case INVESTIR: return 4;
            case RECRUTAR: return 6;
            case REFORCAR: return 3;
            default: return grafo.custo(acao.origem(), acao.alvo());
        }
    }

    public boolean pode(Acao acao) {
        return vencedor() == -1 && estado.paises[jogador].derrotadoPor == -1 && pode(estado, jogador, acao);
    }

    public Acao ataqueAoAlvo(int alvo, int origemPreferida, Evolucao.Estrategia estrategia) {
        if (dono(alvo) == jogador) return null;
        if (origemPreferida >= 0 && grafo.custo(origemPreferida, alvo) > 0) {
            Acao preferida = Acao.atacar(origemPreferida, alvo);
            if (pode(preferida)) return preferida;
        }
        DecisaoGulosa.Opcao melhor = null;
        for (int origem : grafo.vizinhos(alvo)) {
            Acao acao = Acao.atacar(origem, alvo);
            if (pode(acao)) melhor = guloso.comparar(melhor, new DecisaoGulosa.Opcao(acao, guloso.pontuarAtaque(estado, acao, estrategia)));
        }
        return melhor == null ? null : melhor.acao;
    }

    public Combate.Previsao prever(Acao acao) { return Combate.prever(estado, acao); }

    public String descricao(Acao acao) {
        switch (acao.tipo()) {
            case PASSAR: return "Poupar recursos";
            case INVESTIR: return "Investir em " + ATRIBUTOS[acao.alvo()].toLowerCase(java.util.Locale.ROOT);
            case RECRUTAR: return "Recrutar em " + nomeRegiao(acao.alvo());
            case REFORCAR: return "Reforçar " + nomeRegiao(acao.alvo());
            default: return "Atacar " + nomeRegiao(acao.alvo());
        }
    }

    public void proximaRodada(Acao acaoJogador, Evolucao.Estrategia focoJogador) {
        if (vencedor() != -1) return;
        Evolucao.Estrategia[] estrategias = evolucao.ativas();
        estrategias[jogador] = focoJogador;
        resolverRodada(estado, estrategias, sorte, acaoJogador, true);
        if (estado.rodada % 2 == 0) evolucao.avancar(this, estado);
        historico.salvar(estado, evolucao);
    }

    private void resolverRodada(EstadoPartida partida, Evolucao.Estrategia[] estrategias, Random rng,
                                 Acao acaoJogador, boolean registrar) {
        partida.rodada++;
        for (EstadoPartida.Pais pais : partida.paises) {
            pais.perdasAnteriores = pais.perdas;
            pais.perdas = 0;
            pais.mobilizadas = 0;
            pais.efeitos = "";
            pais.escolha = null;
        }
        if (registrar) aplicar(partida, jogador, acaoJogador, estrategias[jogador], rng, true);
        // Alterna a ordem dos adversários
        for (int i = 0; i < dados.length; i++) {
            int pais = (partida.rodada + i) % dados.length;
            if (registrar && pais == jogador) continue;
            DecisaoGulosa.Escolha escolha = guloso.escolher(partida, pais, estrategias[pais]);
            if (registrar && ativo(partida, pais)) partida.paises[pais].escolha = escolha;
            aplicar(partida, pais, escolha.opcao.acao, estrategias[pais], rng, registrar);
        }
        Economia.atualizar(partida, grafo, true);
    }

    boolean pode(EstadoPartida partida, int id, Acao acao) {
        int custo = custo(acao);
        if (custo < 0 || partida.paises[id].caixa < custo) return false;
        switch (acao.tipo()) {
            case PASSAR: return true;
            case INVESTIR: return partida.contarRegioes(id) > 0 && partida.paises[id].atributos[acao.alvo()] < MAX_ATRIBUTO;
            case RECRUTAR: return partida.regioes[acao.alvo()].dono == id && partida.regioes[acao.alvo()].tropas < 24;
            case REFORCAR: return partida.regioes[acao.alvo()].dono == id && partida.regioes[acao.alvo()].reforcos < 5;
            default: return partida.regioes[acao.origem()].dono == id && partida.regioes[acao.alvo()].dono != id
                && partida.regioes[acao.origem()].tropas >= 3;
        }
    }

    private void aplicar(EstadoPartida partida, int id, Acao acao, Evolucao.Estrategia e, Random rng, boolean registrar) {
        EstadoPartida.Pais pais = partida.paises[id];
        if (partida.contarRegioes(id) == 0) {
            if (registrar) pais.decisao = "Sem territórios.";
            return;
        }
        if (!pode(partida, id, acao)) {
            if (registrar) pais.decisao = "A ação programada ficou indisponível.";
            return;
        }
        pais.caixa -= custo(acao);
        switch (acao.tipo()) {
            case PASSAR:
                if (registrar) pais.decisao = "Poupou recursos.";
                break;
            case INVESTIR: {
                int atributo = acao.alvo();
                int antes = pais.atributos[atributo];
                boolean bonus = Economia.bonusInvestimento(atributo, e) && rng.nextDouble() < 0.04 * pais.atributos[POLITICA];
                pais.atributos[atributo] = Math.min(MAX_ATRIBUTO, antes + (bonus ? 2 : 1));
                if (registrar) pais.decisao = descricao(acao) + " · " + antes + " → " + pais.atributos[atributo]
                    + (bonus && antes + 1 < MAX_ATRIBUTO ? " (bônus político)" : "") + ".";
                break;
            }
            case RECRUTAR: {
                EstadoPartida.Regiao regiao = partida.regioes[acao.alvo()];
                int reforco = Math.min(3, 24 - regiao.tropas);
                regiao.tropas += reforco;
                if (registrar) pais.decisao = descricao(acao) + " · +" + reforco + " tropas.";
                break;
            }
            case REFORCAR:
                partida.regioes[acao.alvo()].reforcos++;
                if (registrar) pais.decisao = descricao(acao) + " · +2 de defesa.";
                break;
            case ATACAR:
                Combate.disputar(partida, acao, rng, registrar, this);
                break;
        }
    }

    boolean ativo(EstadoPartida partida, int id) { return partida.contarRegioes(id) > 0; }

    double fitness(EstadoPartida base, Evolucao.Estrategia[] perfis, int id, Evolucao.Estrategia candidata, long semente) {
        EstadoPartida simulada = base.copiar();
        Evolucao.Estrategia[] teste = perfis.clone();
        teste[id] = candidata;
        Random rng = new Random(semente);
        int baixas = 0;
        // Simula duas rodadas
        for (int i = 0; i < 2; i++) {
            resolverRodada(simulada, teste, rng, Acao.passar(), false);
            baixas += simulada.paises[id].perdas;
        }
        EstadoPartida.Pais antes = base.paises[id], depois = simulada.paises[id];
        return 16 * (simulada.contarRegioes(id) - base.contarRegioes(id)) + 1.6 * (depois.pib - antes.pib)
            + 0.45 * (depois.caixa - antes.caixa) + 0.6 * (simulada.contarTropas(id) - base.contarTropas(id))
            - 1.2 * baixas - (ativo(simulada, id) ? 0 : 25);
    }
}
