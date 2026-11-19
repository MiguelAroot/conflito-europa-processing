import java.util.HashMap;

final class EstadoPartida {
    static final class Pais {
        final int[] atributos;
        int caixa = 24, pib, parceiros, renda, perdas, perdasAnteriores, mobilizadas;
        int derrotadoPor = -1;
        String decisao = "Início da partida.", efeitos = "";
        DecisaoGulosa.Escolha escolha;

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

    static final class Regiao {
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

    final Pais[] paises;
    final Regiao[] regioes;
    // Suspensão do comércio
    final HashMap<Integer, Integer> bloqueiosComerciais = new HashMap<>();
    int rodada;

    EstadoPartida(int nPaises, int nRegioes) {
        paises = new Pais[nPaises];
        regioes = new Regiao[nRegioes];
    }

    EstadoPartida copiar() {
        EstadoPartida copia = new EstadoPartida(paises.length, regioes.length);
        copia.rodada = rodada;
        for (int i = 0; i < paises.length; i++) copia.paises[i] = paises[i].copiar();
        for (int i = 0; i < regioes.length; i++) copia.regioes[i] = regioes[i].copiar();
        copia.bloqueiosComerciais.putAll(bloqueiosComerciais);
        return copia;
    }

    int contarRegioes(int id) {
        int total = 0;
        for (Regiao regiao : regioes) if (regiao.dono == id) total++;
        return total;
    }

    int contarTropas(int id) {
        int total = 0;
        for (Regiao regiao : regioes) if (regiao.dono == id) total += regiao.tropas;
        return total;
    }
}
