final class DecisaoGulosa {
    static final class Opcao {
        final Partida.Acao acao;
        final double pontos;

        Opcao(Partida.Acao acao, double pontos) {
            this.acao = acao;
            this.pontos = pontos;
        }
    }

    static final class Escolha {
        final Opcao opcao;
        final boolean emergencia;
        private final Opcao[] notas;

        Escolha(Opcao opcao, Opcao[] notas, boolean emergencia) {
            this.opcao = opcao;
            this.notas = notas.clone();
            this.notas[opcao.acao.tipo().ordinal()] = opcao;
            this.emergencia = emergencia;
        }

        double melhorNota(Partida.Tipo tipo) {
            Opcao nota = notas[tipo.ordinal()];
            return nota == null ? Double.NaN : nota.pontos;
        }
    }

    private final Partida jogo;

    DecisaoGulosa(Partida jogo) { this.jogo = jogo; }

    private Opcao avaliar(Opcao[] notas, Opcao melhor, Opcao candidata) {
        int tipo = candidata.acao.tipo().ordinal();
        notas[tipo] = comparar(notas[tipo], candidata);
        return comparar(melhor, candidata);
    }

    Escolha escolher(EstadoPartida partida, int id, Evolucao.Estrategia e) {
        Opcao melhor = new Opcao(Partida.Acao.passar(), 0);
        Opcao[] notas = new Opcao[Partida.Tipo.values().length];
        notas[Partida.Tipo.PASSAR.ordinal()] = melhor;
        Partida.Acao recrutarNaFronteira = null;
        EstadoPartida.Pais pais = partida.paises[id];
        if (partida.contarRegioes(id) == 0) return new Escolha(melhor, notas, false);
        for (int atributo = 0; atributo < Partida.ATRIBUTOS.length; atributo++) {
            Partida.Acao acao = Partida.Acao.investir(atributo);
            if (!jogo.pode(partida, id, acao)) continue;
            double bonus = Economia.bonusInvestimento(atributo, e) ? 1 + 0.04 * pais.atributos[Partida.POLITICA] : 1;
            double pontos = pontuarInvestimento(pais, atributo, e);
            melhor = avaliar(notas, melhor, new Opcao(acao, pontos * bonus - 0.20 * jogo.custo(acao)));
        }

        for (int i = 0; i < partida.regioes.length; i++) {
            EstadoPartida.Regiao origem = partida.regioes[i];
            if (origem.dono != id) continue;
            double ameaca = 0;
            for (int vizinho : jogo.grafo.vizinhos(i)) {
                EstadoPartida.Regiao alvo = partida.regioes[vizinho];
                if (alvo.dono == id) continue;
                ameaca = Math.max(ameaca, Math.min(1.0, (double) alvo.tropas / Math.max(1, origem.tropas) / 1.5));
                Partida.Acao acao = Partida.Acao.atacar(i, vizinho);
                if (jogo.pode(partida, id, acao)) {
                    Opcao ataque = new Opcao(acao, pontuarAtaque(partida, acao, e));
                    melhor = avaliar(notas, melhor, ataque);
                }
            }
            Partida.Acao recrutar = Partida.Acao.recrutar(i);
            if (jogo.pode(partida, id, recrutar)) {
                if (ameaca > 0 && origem.tropas < 3) recrutarNaFronteira = recrutar;
                double espaco = Math.max(0, 1 - origem.tropas / 24.0);
                double pontos = (e.expansao() * 8 + e.protecao() * (4 + 4 * ameaca)) * espaco - 0.20 * jogo.custo(recrutar);
                melhor = avaliar(notas, melhor, new Opcao(recrutar, pontos));
            }
            Partida.Acao reforcar = Partida.Acao.reforcar(i);
            if (jogo.pode(partida, id, reforcar)) {
                double pontos = e.protecao() * (2 + 7 * ameaca) / (1 + 0.22 * origem.reforcos) - 0.20 * jogo.custo(reforcar);
                melhor = avaliar(notas, melhor, new Opcao(reforcar, pontos));
            }
        }
        if (melhor.acao.tipo() == Partida.Tipo.PASSAR) {
            Opcao ataque = notas[Partida.Tipo.ATACAR.ordinal()];
            if (ataque != null) return new Escolha(ataque, notas, true);
            if (recrutarNaFronteira != null) return new Escolha(new Opcao(recrutarNaFronteira, 0), notas, true);
        }
        return new Escolha(melhor, notas, false);
    }

    Opcao comparar(Opcao atual, Opcao candidata) {
        return atual == null || candidata.pontos > atual.pontos ? candidata : atual;
    }

    private double pontuarInvestimento(EstadoPartida.Pais pais, int atributo, Evolucao.Estrategia e) {
        switch (atributo) {
            case Partida.MERCADO: return e.economia() * (8.2 - 0.15 * pais.atributos[Partida.MERCADO]);
            case Partida.COMERCIO: return e.economia() * (4.2 + Math.min(4, pais.parceiros) * 0.9);
            case Partida.FORCAS: return (e.expansao() * 5.5 + e.protecao() * 4.0) * (1 - 0.025 * pais.atributos[Partida.FORCAS]);
            case Partida.INFRA: return e.protecao() * (7.5 - 0.16 * pais.atributos[Partida.INFRA]);
            default: return 1.4 + 2.8 * e.pesoMaior() - 0.06 * pais.atributos[Partida.POLITICA];
        }
    }

    double pontuarAtaque(EstadoPartida partida, Partida.Acao acao, Evolucao.Estrategia e) {
        Combate.Previsao previsao = Combate.prever(partida, acao);
        int alvo = partida.regioes[acao.alvo()].dono;
        double valor = 21 * e.expansao() + (4 + 0.25 * partida.paises[alvo].atributos[Partida.MERCADO]) * e.economia();
        return previsao.chance() * valor - 0.34 * jogo.custo(acao)
            - previsao.perdas() * (0.58 + 0.8 * e.economia() + 0.6 * e.protecao())
            - (1 - previsao.chance()) * 2;
    }
}
