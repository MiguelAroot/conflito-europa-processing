import java.util.Random;

public final class Combate {
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

    static Previsao prever(EstadoPartida partida, Partida.Acao acao) {
        EstadoPartida.Regiao origem = partida.regioes[acao.origem()];
        int enviadas = Math.min(origem.tropas - 1, (origem.tropas * 3 + 2) / 4);
        double ataque = enviadas * qualidade(partida.paises[origem.dono]);
        double defesa = defesa(partida, acao.alvo());
        double chance = Math.max(0.05, Math.min(0.95, 0.5 + 1.12 * (ataque - defesa) / (ataque + defesa)));
        double perdas = enviadas * (0.08 + 0.54 * defesa / (ataque + defesa));
        return new Previsao(enviadas, ataque, defesa, chance, perdas);
    }

    static double defesa(EstadoPartida partida, int id) {
        EstadoPartida.Regiao regiao = partida.regioes[id];
        EstadoPartida.Pais dono = partida.paises[regiao.dono];
        return regiao.tropas * qualidade(dono) + 0.36 * dono.atributos[Partida.INFRA] + 2 * regiao.reforcos;
    }

    private static double qualidade(EstadoPartida.Pais pais) { return 1 + 0.075 * pais.atributos[Partida.FORCAS]; }

    static void disputar(EstadoPartida partida, Partida.Acao acao, Random rng, boolean registrar, Partida jogo) {
        EstadoPartida.Regiao origem = partida.regioes[acao.origem()];
        EstadoPartida.Regiao alvo = partida.regioes[acao.alvo()];
        int atacante = origem.dono, defensor = alvo.dono;
        EstadoPartida.Pais paisA = partida.paises[atacante], paisD = partida.paises[defensor];
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
        Economia.suspenderComercio(partida, atacante, defensor);
        if (registrar) {
            paisA.decisao = (venceu ? "Conquistou " + jogo.nomePais(defensor) : "Atacou " + jogo.nomeRegiao(acao.alvo()))
                + " · " + Math.round(p.chance() * 100) + "% de chance · " + baixasA + " baixas próprias.";
            if (!paisD.efeitos.isEmpty()) paisD.efeitos += " ";
            if (venceu) paisD.efeitos += "Dominado por " + jogo.nomePais(atacante) + ". ";
            paisD.efeitos += jogo.nomePais(atacante) + " disputou " + jogo.nomeRegiao(acao.alvo())
                + " · " + baixasD + " baixas na defesa.";
        }
    }

    private static int sortearBaixas(double esperadas, int limite, Random rng) {
        return Math.max(0, Math.min(limite, (int) Math.round(esperadas * (0.8 + 0.4 * rng.nextDouble()))));
    }

    private static void dominar(EstadoPartida partida, int atacante, int defensor) {
        EstadoPartida.Pais venceu = partida.paises[atacante];
        EstadoPartida.Pais perdeu = partida.paises[defensor];
        perdeu.derrotadoPor = atacante;
        perdeu.caixa = 0;
        for (int i = 0; i < Partida.ATRIBUTOS.length; i++) {
            venceu.atributos[i] = Math.min(Partida.MAX_ATRIBUTO, venceu.atributos[i] + perdeu.atributos[i]);
            perdeu.atributos[i] = 0;
        }
        for (EstadoPartida.Regiao regiao : partida.regioes) {
            if (regiao.dono == defensor) {
                regiao.dono = atacante;
                regiao.tropas = 0;
            }
        }
    }
}
