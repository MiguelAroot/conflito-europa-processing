import java.util.ArrayList;
import java.util.HashSet;

final class Economia {
    private static int par(int a, int b, int nPaises) { return Math.min(a, b) * nPaises + Math.max(a, b); }

    static void atualizar(EstadoPartida partida, Grafo grafo, boolean cobrar) {
        int nPaises = partida.paises.length;
        ArrayList<HashSet<Integer>> parceiros = new ArrayList<>(nPaises);
        int[] territorios = new int[nPaises];
        for (int i = 0; i < nPaises; i++) parceiros.add(new HashSet<>());
        for (EstadoPartida.Regiao regiao : partida.regioes) territorios[regiao.dono]++;
        for (Grafo.Aresta aresta : grafo.arestas()) {
            int a = partida.regioes[aresta.a()].dono, b = partida.regioes[aresta.b()].dono;
            if (a == b || partida.bloqueiosComerciais.getOrDefault(par(a, b, nPaises), -1) >= partida.rodada) continue;
            parceiros.get(a).add(b);
            parceiros.get(b).add(a);
        }
        for (int id = 0; id < nPaises; id++) {
            EstadoPartida.Pais pais = partida.paises[id];
            pais.parceiros = parceiros.get(id).size();
            int comercio = Math.min(4, pais.parceiros) * (pais.atributos[Partida.COMERCIO] + 4) / 5;
            int impacto = 2 * pais.perdas + pais.perdasAnteriores + pais.mobilizadas / 3;
            pais.pib = territorios[id] == 0 ? 0 : Math.max(0, 6 + 2 * pais.atributos[Partida.MERCADO] + 2 * territorios[id] + comercio - impacto);
            pais.renda = pais.pib / 3;
            if (cobrar) pais.caixa += pais.renda;
        }
        partida.bloqueiosComerciais.values().removeIf(ate -> ate < partida.rodada);
    }

    static void suspenderComercio(EstadoPartida partida, int a, int b) {
        partida.bloqueiosComerciais.put(par(a, b, partida.paises.length), partida.rodada + 1);
    }

    static boolean bonusInvestimento(int atributo, Evolucao.Estrategia estrategia) {
        switch (estrategia.foco()) {
            case 0: return atributo == Partida.FORCAS;
            case 1: return atributo == Partida.INFRA;
            default: return atributo == Partida.MERCADO || atributo == Partida.COMERCIO;
        }
    }
}
