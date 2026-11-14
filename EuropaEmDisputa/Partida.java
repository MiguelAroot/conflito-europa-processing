import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
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

    public static final class Previsao {
        private final int enviadas;
        private final double ataque, defesa, chance, perdas;

        private Previsao(int enviadas, double ataque, double defesa, double chance, double perdas) {
            this.enviadas = enviadas;
            this.ataque = ataque;
            this.defesa = defesa;
            this.chance = chance;
            this.perdas = perdas;
        }

        public int enviadas() { return enviadas; }
        public double ataque() { return ataque; }
        public double defesa() { return defesa; }
        public double chance() { return chance; }
        public double perdas() { return perdas; }
    }

    public static final class Resumo {
        private final int[] atributos;
        private final int pib, caixa, tropas, regioes, parceiros, renda, perdas;
        private final int derrotadoPor;
        private final String decisao, efeitos;
        private final double pontos, fitness;
        private final Evolucao.Estrategia estrategia;

        private Resumo(Pais p, int tropas, int regioes, Evolucao.Estrategia estrategia, double fitness) {
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
            pontos = p.pontos;
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
        public double pontos() { return pontos; }
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

    private static final class Opcao {
        final Acao acao;
        final double pontos;

        Opcao(Acao acao, double pontos) {
            this.acao = acao;
            this.pontos = pontos;
        }
    }

    private static final class Pais {
        final int[] atributos;
        int caixa = 24, pib, parceiros, renda, perdas, perdasAnteriores, mobilizadas;
        int derrotadoPor = -1;
        String decisao = "Início da partida.", efeitos = "";
        double pontos = Double.NaN;

        Pais(int[] atributos) { this.atributos = atributos.clone(); }

        Pais copiar() {
            Pais copia = new Pais(atributos);
            copia.caixa = caixa;
            copia.pib = pib;
            copia.parceiros = parceiros;
            copia.renda = renda;
            copia.perdas = perdas;
            copia.perdasAnteriores = perdasAnteriores;
            copia.mobilizadas = mobilizadas;
            copia.derrotadoPor = derrotadoPor;
            return copia;
        }
    }

    private static final class Regiao {
        int dono, tropas, reforcos;

        Regiao(int dono, int tropas) {
            this.dono = dono;
            this.tropas = tropas;
        }

        Regiao copiar() {
            Regiao copia = new Regiao(dono, tropas);
            copia.reforcos = reforcos;
            return copia;
        }
    }

    static final class Estado {
        final Pais[] paises;
        final Regiao[] regioes;
        // Suspensão do comércio
        final HashMap<Integer, Integer> bloqueiosComerciais = new HashMap<>();
        int rodada;

        Estado(int nPaises, int nRegioes) {
            paises = new Pais[nPaises];
            regioes = new Regiao[nRegioes];
        }

        Estado copiar() {
            Estado copia = new Estado(paises.length, regioes.length);
            copia.rodada = rodada;
            for (int i = 0; i < paises.length; i++) copia.paises[i] = paises[i].copiar();
            for (int i = 0; i < regioes.length; i++) copia.regioes[i] = regioes[i].copiar();
            copia.bloqueiosComerciais.putAll(bloqueiosComerciais);
            return copia;
        }
    }

    private final DadosPais[] dados;
    public final Grafo grafo;
    public final int jogador;
    private final Estado estado;
    private final Evolucao evolucao;
    private final Random sorte;
    private final ArrayList<Quadro> historico = new ArrayList<>();

    public Partida(DadosPais[] dados, Grafo grafo, int jogador, long semente) {
        this.dados = dados.clone();
        this.grafo = grafo;
        this.jogador = jogador;
        sorte = new Random(semente);
        estado = new Estado(dados.length, grafo.tamanho);
        for (int i = 0; i < dados.length; i++) estado.paises[i] = new Pais(dados[i].atributos);
        for (int i = 0; i < grafo.tamanho; i++) estado.regioes[i] = new Regiao(i / 2, 4 + sorte.nextInt(8));
        evolucao = new Evolucao(dados.length, new Random(semente ^ 0x5DEECE66DL));
        atualizarEconomia(estado, false);
        salvarQuadro();
    }

    public int rodada() { return estado.rodada; }
    public int geracao() { return evolucao.geracao(); }
    public Quadro quadro(int rodada) { return historico.get(rodada); }
    public String nomeRegiao(int regiao) { return dados[regiao / 2].nome() + " · " + (regiao % 2 == 0 ? "Norte" : "Sul"); }
    public int dono(int regiao) { return estado.regioes[regiao].dono; }

    public int vencedor() {
        int dono = estado.regioes[0].dono;
        for (Regiao regiao : estado.regioes) if (regiao.dono != dono) return -1;
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
        Opcao melhor = null;
        for (int origem : grafo.vizinhos(alvo)) {
            Acao acao = Acao.atacar(origem, alvo);
            if (pode(acao)) melhor = comparar(melhor, new Opcao(acao, pontuarAtaque(estado, acao, estrategia)));
        }
        return melhor == null ? null : melhor.acao;
    }

    public Previsao prever(Acao acao) { return prever(estado, acao); }

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
        salvarQuadro();
    }

    private void resolverRodada(Estado partida, Evolucao.Estrategia[] estrategias, Random rng,
                                 Acao acaoJogador, boolean registrar) {
        partida.rodada++;
        for (Pais pais : partida.paises) {
            pais.perdasAnteriores = pais.perdas;
            pais.perdas = 0;
            pais.mobilizadas = 0;
            pais.efeitos = "";
            pais.pontos = Double.NaN;
        }
        if (registrar) aplicar(partida, jogador, acaoJogador, estrategias[jogador], rng, true);
        // Alterna a ordem dos adversários
        for (int i = 0; i < dados.length; i++) {
            int pais = (partida.rodada + i) % dados.length;
            if (registrar && pais == jogador) continue;
            Opcao opcao = guloso(partida, pais, estrategias[pais]);
            partida.paises[pais].pontos = opcao.pontos;
            aplicar(partida, pais, opcao.acao, estrategias[pais], rng, registrar);
        }
        atualizarEconomia(partida, true);
    }

    private boolean pode(Estado partida, int id, Acao acao) {
        int custo = custo(acao);
        if (custo < 0 || partida.paises[id].caixa < custo) return false;
        switch (acao.tipo()) {
            case PASSAR: return true;
            case INVESTIR: return contarRegioes(partida, id) > 0 && partida.paises[id].atributos[acao.alvo()] < MAX_ATRIBUTO;
            case RECRUTAR: return partida.regioes[acao.alvo()].dono == id && partida.regioes[acao.alvo()].tropas < 24;
            case REFORCAR: return partida.regioes[acao.alvo()].dono == id && partida.regioes[acao.alvo()].reforcos < 5;
            default: return partida.regioes[acao.origem()].dono == id && partida.regioes[acao.alvo()].dono != id
                && partida.regioes[acao.origem()].tropas >= 3;
        }
    }

    private Opcao guloso(Estado partida, int id, Evolucao.Estrategia e) {
        Opcao melhor = new Opcao(Acao.passar(), 0);
        Opcao melhorAtaque = null;
        Acao recrutarNaFronteira = null;
        Pais pais = partida.paises[id];
        if (contarRegioes(partida, id) == 0) return melhor;
        for (int atributo = 0; atributo < ATRIBUTOS.length; atributo++) {
            Acao acao = Acao.investir(atributo);
            if (!pode(partida, id, acao)) continue;
            double bonus = bonusInvestimento(atributo, e) ? 1 + 0.04 * pais.atributos[POLITICA] : 1;
            double pontos = pontuarInvestimento(pais, atributo, e);
            melhor = comparar(melhor, new Opcao(acao, pontos * bonus - 0.20 * custo(acao)));
        }

        for (int i = 0; i < partida.regioes.length; i++) {
            Regiao origem = partida.regioes[i];
            if (origem.dono != id) continue;
            double ameaca = 0;
            for (int vizinho : grafo.vizinhos(i)) {
                Regiao alvo = partida.regioes[vizinho];
                if (alvo.dono == id) continue;
                ameaca = Math.max(ameaca, Math.min(1.0, (double) alvo.tropas / Math.max(1, origem.tropas) / 1.5));
                Acao acao = Acao.atacar(i, vizinho);
                if (pode(partida, id, acao)) {
                    Opcao ataque = new Opcao(acao, pontuarAtaque(partida, acao, e));
                    melhor = comparar(melhor, ataque);
                    melhorAtaque = comparar(melhorAtaque, ataque);
                }
            }
            Acao recrutar = Acao.recrutar(i);
            if (pode(partida, id, recrutar)) {
                if (ameaca > 0 && origem.tropas < 3) recrutarNaFronteira = recrutar;
                double espaco = Math.max(0, 1 - origem.tropas / 24.0);
                double pontos = (e.expansao() * 8 + e.protecao() * (4 + 4 * ameaca)) * espaco - 0.20 * custo(recrutar);
                melhor = comparar(melhor, new Opcao(recrutar, pontos));
            }
            Acao reforcar = Acao.reforcar(i);
            if (pode(partida, id, reforcar)) {
                double pontos = e.protecao() * (2 + 7 * ameaca) / (1 + 0.22 * origem.reforcos) - 0.20 * custo(reforcar);
                melhor = comparar(melhor, new Opcao(reforcar, pontos));
            }
        }
        if (melhor.acao.tipo() == Tipo.PASSAR) {
            if (melhorAtaque != null) return melhorAtaque;
            if (recrutarNaFronteira != null) return new Opcao(recrutarNaFronteira, 0);
        }
        return melhor;
    }

    private Opcao comparar(Opcao atual, Opcao candidata) {
        return atual == null || candidata.pontos > atual.pontos ? candidata : atual;
    }

    private double pontuarInvestimento(Pais pais, int atributo, Evolucao.Estrategia e) {
        switch (atributo) {
            case MERCADO: return e.economia() * (8.2 - 0.15 * pais.atributos[MERCADO]);
            case COMERCIO: return e.economia() * (4.2 + Math.min(4, pais.parceiros) * 0.9);
            case FORCAS: return (e.expansao() * 5.5 + e.protecao() * 4.0) * (1 - 0.025 * pais.atributos[FORCAS]);
            case INFRA: return e.protecao() * (7.5 - 0.16 * pais.atributos[INFRA]);
            default: return 1.4 + 2.8 * e.pesoMaior() - 0.06 * pais.atributos[POLITICA];
        }
    }

    private double pontuarAtaque(Estado partida, Acao acao, Evolucao.Estrategia e) {
        Previsao previsao = prever(partida, acao);
        int alvo = partida.regioes[acao.alvo()].dono;
        double valor = 21 * e.expansao() + (4 + 0.25 * partida.paises[alvo].atributos[MERCADO]) * e.economia();
        return previsao.chance() * valor - 0.34 * custo(acao)
            - previsao.perdas() * (0.58 + 0.8 * e.economia() + 0.6 * e.protecao())
            - (1 - previsao.chance()) * 2;
    }

    private Previsao prever(Estado partida, Acao acao) {
        Regiao origem = partida.regioes[acao.origem()];
        int enviadas = Math.min(origem.tropas - 1, (origem.tropas * 3 + 2) / 4);
        double ataque = enviadas * qualidade(partida.paises[origem.dono]);
        double defesa = defesa(partida, acao.alvo());
        double chance = Math.max(0.05, Math.min(0.95, 0.5 + 1.12 * (ataque - defesa) / (ataque + defesa)));
        double perdas = enviadas * (0.08 + 0.54 * defesa / (ataque + defesa));
        return new Previsao(enviadas, ataque, defesa, chance, perdas);
    }

    private double defesa(Estado partida, int id) {
        Regiao regiao = partida.regioes[id];
        Pais dono = partida.paises[regiao.dono];
        return regiao.tropas * qualidade(dono) + 0.36 * dono.atributos[INFRA] + 2 * regiao.reforcos;
    }

    private double qualidade(Pais pais) { return 1 + 0.075 * pais.atributos[FORCAS]; }

    private boolean bonusInvestimento(int atributo, Evolucao.Estrategia estrategia) {
        switch (estrategia.foco()) {
            case 0: return atributo == FORCAS;
            case 1: return atributo == INFRA;
            default: return atributo == MERCADO || atributo == COMERCIO;
        }
    }

    private void aplicar(Estado partida, int id, Acao acao, Evolucao.Estrategia e, Random rng, boolean registrar) {
        Pais pais = partida.paises[id];
        if (contarRegioes(partida, id) == 0) {
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
                boolean bonus = bonusInvestimento(atributo, e) && rng.nextDouble() < 0.04 * pais.atributos[POLITICA];
                pais.atributos[atributo] = Math.min(MAX_ATRIBUTO, antes + (bonus ? 2 : 1));
                if (registrar) pais.decisao = descricao(acao) + " · " + antes + " → " + pais.atributos[atributo]
                    + (bonus && antes + 1 < MAX_ATRIBUTO ? " (bônus político)" : "") + ".";
                break;
            }
            case RECRUTAR: {
                Regiao regiao = partida.regioes[acao.alvo()];
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
                disputar(partida, acao, rng, registrar);
                break;
        }
    }

    private void disputar(Estado partida, Acao acao, Random rng, boolean registrar) {
        Regiao origem = partida.regioes[acao.origem()];
        Regiao alvo = partida.regioes[acao.alvo()];
        int atacante = origem.dono, defensor = alvo.dono;
        Pais paisA = partida.paises[atacante], paisD = partida.paises[defensor];
        Previsao p = prever(partida, acao);
        boolean venceu = rng.nextDouble() < p.chance();
        int baixasA = sortearBaixas(p.perdas() * (venceu ? 0.9 : 1.25), p.enviadas() - (venceu ? 1 : 0), rng);
        double perdasDefesa = alvo.tropas * (0.09 + 0.58 * p.ataque() / (p.ataque() + p.defesa()));
        int baixasD = sortearBaixas(perdasDefesa * (venceu ? 1.22 : 0.83), alvo.tropas, rng);
        paisA.mobilizadas += p.enviadas();
        paisD.mobilizadas += alvo.tropas;
        origem.tropas -= baixasA;
        alvo.tropas -= baixasD;
        if (venceu) {
            int sobreviventes = p.enviadas() - baixasA;
            origem.tropas -= sobreviventes;
            dominar(partida, atacante, defensor);
            alvo.tropas = sobreviventes;
            alvo.reforcos = Math.max(0, alvo.reforcos - 1);
        }
        paisA.perdas += baixasA;
        paisD.perdas += baixasD;
        partida.bloqueiosComerciais.put(par(atacante, defensor), partida.rodada + 1);
        if (registrar) {
            paisA.decisao = (venceu ? "Conquistou " + dados[defensor].nome() : "Atacou " + nomeRegiao(acao.alvo()))
                + " · " + Math.round(p.chance() * 100) + "% de chance · " + baixasA + " baixas próprias.";
            if (!paisD.efeitos.isEmpty()) paisD.efeitos += " ";
            if (venceu) paisD.efeitos += "Dominado por " + dados[atacante].nome() + ". ";
            paisD.efeitos += dados[atacante].nome() + " disputou " + nomeRegiao(acao.alvo())
                + " · " + baixasD + " baixas na defesa.";
        }
    }

    private int sortearBaixas(double esperadas, int limite, Random rng) {
        return Math.max(0, Math.min(limite, (int) Math.round(esperadas * (0.8 + 0.4 * rng.nextDouble()))));
    }

    private void dominar(Estado partida, int atacante, int defensor) {
        Pais venceu = partida.paises[atacante];
        Pais perdeu = partida.paises[defensor];
        perdeu.derrotadoPor = atacante;
        perdeu.caixa = 0;
        for (int i = 0; i < ATRIBUTOS.length; i++) {
            venceu.atributos[i] = Math.min(MAX_ATRIBUTO, venceu.atributos[i] + perdeu.atributos[i]);
            perdeu.atributos[i] = 0;
        }
        for (Regiao regiao : partida.regioes) {
            if (regiao.dono == defensor) {
                regiao.dono = atacante;
                regiao.tropas = 0;
            }
        }
    }

    private int par(int a, int b) { return Math.min(a, b) * dados.length + Math.max(a, b); }

    private void atualizarEconomia(Estado partida, boolean cobrar) {
        ArrayList<HashSet<Integer>> parceiros = new ArrayList<>(dados.length);
        int[] territorios = new int[dados.length];
        for (int i = 0; i < dados.length; i++) parceiros.add(new HashSet<>());
        for (Regiao regiao : partida.regioes) territorios[regiao.dono]++;
        for (Grafo.Aresta aresta : grafo.arestas()) {
            int a = partida.regioes[aresta.a()].dono, b = partida.regioes[aresta.b()].dono;
            if (a == b || partida.bloqueiosComerciais.getOrDefault(par(a, b), -1) >= partida.rodada) continue;
            parceiros.get(a).add(b);
            parceiros.get(b).add(a);
        }
        for (int id = 0; id < dados.length; id++) {
            Pais pais = partida.paises[id];
            pais.parceiros = parceiros.get(id).size();
            int comercio = Math.min(4, pais.parceiros) * (pais.atributos[COMERCIO] + 4) / 5;
            int impacto = 2 * pais.perdas + pais.perdasAnteriores + pais.mobilizadas / 3;
            pais.pib = territorios[id] == 0 ? 0 : Math.max(0, 6 + 2 * pais.atributos[MERCADO] + 2 * territorios[id] + comercio - impacto);
            pais.renda = pais.pib / 3;
            if (cobrar) pais.caixa += pais.renda;
        }
        partida.bloqueiosComerciais.values().removeIf(ate -> ate < partida.rodada);
    }

    private int contarRegioes(Estado partida, int id) {
        int total = 0;
        for (Regiao regiao : partida.regioes) if (regiao.dono == id) total++;
        return total;
    }

    private int contarTropas(Estado partida, int id) {
        int total = 0;
        for (Regiao regiao : partida.regioes) if (regiao.dono == id) total += regiao.tropas;
        return total;
    }

    boolean ativo(Estado partida, int id) { return contarRegioes(partida, id) > 0; }

    double fitness(Estado base, Evolucao.Estrategia[] perfis, int id, Evolucao.Estrategia candidata, long semente) {
        Estado simulada = base.copiar();
        Evolucao.Estrategia[] teste = perfis.clone();
        teste[id] = candidata;
        Random rng = new Random(semente);
        int baixas = 0;
        // Simula duas rodadas
        for (int i = 0; i < 2; i++) {
            resolverRodada(simulada, teste, rng, Acao.passar(), false);
            baixas += simulada.paises[id].perdas;
        }
        Pais antes = base.paises[id], depois = simulada.paises[id];
        return 16 * (contarRegioes(simulada, id) - contarRegioes(base, id)) + 1.6 * (depois.pib - antes.pib)
            + 0.45 * (depois.caixa - antes.caixa) + 0.6 * (contarTropas(simulada, id) - contarTropas(base, id))
            - 1.2 * baixas - (ativo(simulada, id) ? 0 : 25);
    }

    private void salvarQuadro() {
        Resumo[] resumos = new Resumo[dados.length];
        for (int i = 0; i < dados.length; i++) {
            Pais p = estado.paises[i];
            resumos[i] = new Resumo(p, contarTropas(estado, i), contarRegioes(estado, i), evolucao.ativa(i), evolucao.melhorFitness(i));
        }
        int[] donos = new int[grafo.tamanho], tropas = new int[grafo.tamanho];
        double[] defesas = new double[grafo.tamanho];
        for (int i = 0; i < grafo.tamanho; i++) {
            donos[i] = estado.regioes[i].dono;
            tropas[i] = estado.regioes[i].tropas;
            defesas[i] = defesa(estado, i);
        }
        historico.add(new Quadro(estado.rodada, evolucao.geracao(), resumos, donos, tropas, defesas));
    }
}
