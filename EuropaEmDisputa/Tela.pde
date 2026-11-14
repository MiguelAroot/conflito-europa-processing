class Botao {
  final float x, y, w, h;
  final boolean ativo;
  final Runnable acao;

  Botao(float x, float y, float w, float h, boolean ativo, Runnable acao) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.ativo = ativo;
    this.acao = acao;
  }

  boolean contem(float px, float py) { return px >= x && px < x + w && py >= y && py < y + h; }
}

void botao(float x, float y, float w, float h, String rotulo, boolean ativo, boolean marcado, Runnable acao) {
  Botao b = new Botao(x, y, w, h, ativo, acao);
  botoes.add(b);
  stroke(marcado && ativo ? COR_DESTAQUE : COR_LINHA);
  strokeWeight(1);
  fill(!ativo ? 0xffebece6 : marcado ? COR_DESTAQUE : b.contem(xNaTela(mouseX), yNaTela(mouseY)) ? 0xffe3eceb : 0xfffdfdf8);
  rect(x, y, w, h, 3);
  fill(!ativo ? 0xff73807a : marcado ? 0xffffffff : COR_TEXTO);
  textSize(12);
  textAlign(CENTER, CENTER);
  while (rotulo.length() > 3 && textWidth(rotulo) > w - 12) {
    rotulo = rotulo.substring(0, rotulo.endsWith("…") ? rotulo.length() - 2 : rotulo.length() - 1) + "…";
  }
  text(rotulo, x + w / 2, y + h / 2 - 1);
}

void texto(String conteudo, float x, float y, float tamanho, int cor) {
  fill(cor);
  textSize(tamanho);
  textAlign(LEFT, BASELINE);
  text(conteudo, x, y);
}

void textoDireita(String conteudo, float x, float y, float tamanho, int cor) {
  fill(cor);
  textSize(tamanho);
  textAlign(RIGHT, BASELINE);
  text(conteudo, x, y);
}

void paragrafo(String conteudo, float x, float y, float w, float h, float tamanho, int cor) {
  fill(cor);
  textSize(tamanho);
  textLeading(tamanho + 4);
  textAlign(LEFT, TOP);
  text(conteudo, x, y, w, h);
}

void divisoria(float y) {
  stroke(COR_LINHA);
  strokeWeight(1);
  line(X_PAINEL, y, X_PAINEL + W_PAINEL, y);
}

void desenharCabecalho() {
  texto("Europa em disputa", 18, 34, 25, COR_TEXTO);
  textoDireita("Rodada " + partida.rodada() + "   ·   Geração " + partida.geracao(), 1101, 33, 16, COR_TEXTO);
  botao(615, 12, 129, 27, telaCheia ? "Sair da tela cheia" : "Tela cheia · F11", true, telaCheia, () -> alternarTelaCheia());
  texto(paises.length + " países  ·  " + grafo.tamanho + " regiões  ·  " + grafo.arestas().size() + " ligações", 18, 66, 12, COR_SUAVE);
  botao(607, 45, 137, 25, "Grafo completo", true, grafoCompleto, () -> grafoCompleto = !grafoCompleto);
  texto("GISCO 2021 · © EuroGeographics pelos limites administrativos · Natural Earth", 18, 705, 11, COR_SUAVE);
  stroke(0xffc6cdc5);
  strokeWeight(1);
  line(754, 46, 754, 705);
}

void desenharPainel(Partida.Quadro quadro, Partida.Acao ataque) {
  int escolhido = regiaoFoco / 2;
  float x = X_PAINEL, w = W_PAINEL;
  int vencedor = partida.vencedor();
  if (podeEscolherPais()) {
    String rotulo = vencedor == -1 ? "Jogar como · " + paises[partida.jogador].dados.nome() : "Nova partida";
    botao(x, 53, w, 28, rotulo, true, false, () -> menu = 1);
  } else {
    texto("Seu país · " + paises[partida.jogador].dados.nome(), x, 72, 14, COR_TEXTO);
  }
  botao(x, 89, w, 28, "Ver país · " + paises[escolhido].dados.nome(), true, false, () -> menu = 2);
  String[] nomesAbas = {"Partida", "Histórico", "Evolução"};
  for (int i = 0; i < nomesAbas.length; i++) {
    final int indice = i;
    botao(x + i * 113, 125, 111, 27, nomesAbas[i], true, aba == i, () -> {
      aba = indice;
      if (aba == 0) rodadaVista = partida.rodada();
    });
  }

  if (aba == 0) desenharPartida(quadro, escolhido, ataque);
  if (aba == 1) desenharHistorico(quadro, escolhido);
  if (aba == 2) desenharEvolucao(quadro, escolhido);

  divisoria(643);
  if (vencedor != -1) {
    texto("Vencedor · " + paises[vencedor].dados.nome(), x, 660, 15, COR_TEXTO);
  } else if (partida.quadro(partida.rodada()).pais(partida.jogador).regioes() == 0) {
    texto("Seu país foi dominado. Você está assistindo.", x, 660, 12, COR_SUAVE);
  } else if (planejada.tipo() == Partida.Tipo.PASSAR) {
    texto("Ação programada · poupar recursos", x, 660, 12, COR_SUAVE);
  } else {
    paragrafo("Ação programada · " + partida.descricao(planejada), x, 649, 261, 28, 12, COR_TEXTO);
    botao(x + 274, 650, 63, 21, "Limpar", true, false, () -> planejada = Partida.Acao.passar());
  }
  botao(x, 678, w, 29, vencedor == -1 ? "Próxima rodada" : "Partida encerrada", vencedor == -1, true, () -> avancar());
}

String textoDominacao(Partida.Quadro quadro, int escolhido) {
  int conquistador = quadro.pais(escolhido).derrotadoPor();
  if (conquistador == -1) return "";
  return "Dominado por " + paises[conquistador].dados.nome();
}

void desenharPartida(Partida.Quadro quadro, int escolhido, Partida.Acao ataque) {
  float x = X_PAINEL;
  Partida.Resumo pais = quadro.pais(escolhido);
  Partida.Resumo jogador = quadro.pais(partida.jogador);
  texto("PIB  " + pais.pib(), x, 178, 17, COR_TEXTO);
  texto("Caixa  " + pais.caixa(), x + 165, 178, 17, COR_TEXTO);
  texto("Tropas  " + pais.tropas(), x, 200, 14, COR_TEXTO);
  texto("Regiões  " + pais.regioes(), x + 165, 200, 14, COR_TEXTO);
  texto("Comércio com " + pais.parceiros() + " países  ·  Renda " + pais.renda(), x, 221, 12, COR_SUAVE);

  divisoria(232);
  boolean comparacao = escolhido != partida.jogador;
  texto("Atributos", x, 252, 13, COR_TEXTO);
  if (comparacao) {
    textoDireita("País", x + 264, 252, 12, COR_SUAVE);
    textoDireita("Você", x + W_PAINEL, 252, 12, COR_SUAVE);
  } else {
    textoDireita("Nível", x + W_PAINEL, 252, 12, COR_SUAVE);
  }
  for (int i = 0; i < Partida.ATRIBUTOS.length; i++) {
    float y = 274 + i * 20;
    texto(Partida.ATRIBUTOS[i], x, y, 13, COR_TEXTO);
    textoDireita(pais.atributo(i) + "/20", x + (comparacao ? 264 : W_PAINEL), y, 13, COR_TEXTO);
    if (comparacao) textoDireita(jogador.atributo(i) + "/20", x + W_PAINEL, y, 13, COR_SUAVE);
  }

  botao(x, 368, 79, 26, "Norte", true, regiaoFoco % 2 == 0, () -> selecionarRegiao(escolhido * 2));
  botao(x + 84, 368, 79, 26, "Sul", true, regiaoFoco % 2 == 1, () -> selecionarRegiao(escolhido * 2 + 1));
  botao(x + 168, 368, 169, 26, "Ligações e custos", true, false, () -> menu = 3);
  String dominacao = textoDominacao(quadro, escolhido);
  if (dominacao.isEmpty()) {
    texto("Controle · " + paises[quadro.dono(regiaoFoco)].dados.nome(), x, 413, 13, COR_TEXTO);
    texto("Guarnição " + quadro.guarnicao(regiaoFoco) + "   ·   Defesa " + decimal(quadro.defesa(regiaoFoco)), x, 431, 12, COR_SUAVE);
  } else {
    texto(dominacao, x, 413, 13, COR_TEXTO);
    texto("Controle atual · " + paises[quadro.dono(regiaoFoco)].dados.nome(), x, 431, 12, COR_SUAVE);
  }

  divisoria(442);
  boolean vivo = jogador.regioes() > 0 && partida.vencedor() == -1;
  botao(x, 453, W_PAINEL, 27, "Prioridade · " + Evolucao.FOCOS[focoJogador] + "   ›", vivo, false,
    () -> focoJogador = (focoJogador + 1) % Evolucao.FOCOS.length);
  botao(x, 486, 24, 27, "‹", vivo, false,
    () -> atributo = (atributo + Partida.ATRIBUTOS.length - 1) % Partida.ATRIBUTOS.length);
  botao(x + 28, 486, 170, 27, Partida.ATRIBUTOS[atributo] + "  ›", vivo, false,
    () -> atributo = (atributo + 1) % Partida.ATRIBUTOS.length);
  Partida.Acao investir = Partida.Acao.investir(atributo);
  botao(x + 204, 486, 133, 27, "Investir · 4", partida.pode(investir), false, () -> planejar(investir));

  Partida.Acao recrutar = Partida.Acao.recrutar(regiaoFoco);
  Partida.Acao reforcar = Partida.Acao.reforcar(regiaoFoco);
  botao(x, 520, 108, 28, "Recrutar · 6", partida.pode(recrutar), false, () -> planejar(recrutar));
  botao(x + 113, 520, 108, 28, "Reforçar · 3", partida.pode(reforcar), false, () -> planejar(reforcar));
  botao(x + 226, 520, 111, 28, ataque == null ? "Atacar" : "Atacar · " + partida.custo(ataque),
    ataque != null, false, () -> planejar(ataque));

  if (ataque != null) {
    Partida.Previsao p = partida.prever(ataque);
    texto("Origem · " + partida.nomeRegiao(ataque.origem()), x, 571, 12, COR_TEXTO);
    texto("Vitória " + round((float) (100 * p.chance())) + "%  ·  Baixas estimadas " + decimal(p.perdas()), x, 589, 12, COR_SUAVE);
    texto("Ataque " + decimal(p.ataque()) + "  ×  Defesa " + decimal(p.defesa()), x, 607, 12, COR_SUAVE);
  } else if (partida.vencedor() != -1) {
    texto("Todos os territórios têm o mesmo dono.", x, 572, 12, COR_SUAVE);
  } else if (quadro.dono(regiaoFoco) == partida.jogador) {
    texto("Selecione uma região vizinha para disputar.", x, 572, 12, COR_SUAVE);
  } else if (vivo) {
    texto("Ataque indisponível para esta região.", x, 572, 12, COR_SUAVE);
  } else {
    texto("Seu país ficou sem territórios.", x, 572, 12, COR_SUAVE);
  }
}

void desenharHistorico(Partida.Quadro quadro, int escolhido) {
  float x = X_PAINEL;
  botao(x, 165, 32, 27, "‹", rodadaVista > 0, false, () -> rodadaVista--);
  botao(x + 175, 165, 32, 27, "›", rodadaVista < partida.rodada(), false, () -> rodadaVista++);
  botao(x + 216, 165, 121, 27, "Rodada atual", rodadaVista != partida.rodada(), false, () -> rodadaVista = partida.rodada());
  texto("Rodada " + quadro.rodada() + " de " + partida.rodada(), x + 48, 183, 14, COR_TEXTO);
  Partida.Resumo pais = quadro.pais(escolhido);
  Partida.Resumo anterior = partida.quadro(max(0, quadro.rodada() - 1)).pais(escolhido);
  texto("Resultado da rodada", x, 224, 16, COR_TEXTO);
  textoDireita(textoDominacao(quadro, escolhido), x + W_PAINEL, 224, 11, COR_SUAVE);
  texto("PIB  " + anterior.pib() + " → " + pais.pib(), x, 250, 14, COR_TEXTO);
  texto("Caixa  " + anterior.caixa() + " → " + pais.caixa(), x + 164, 250, 14, COR_TEXTO);
  texto("Tropas  " + anterior.tropas() + " → " + pais.tropas(), x, 275, 14, COR_TEXTO);
  texto("Regiões  " + anterior.regioes() + " → " + pais.regioes(), x + 164, 275, 14, COR_TEXTO);
  texto("Baixas " + pais.perdas() + "  ·  Renda " + pais.renda() + "  ·  Parceiros " + pais.parceiros(), x, 300, 12, COR_SUAVE);
  divisoria(316);
  texto("Atributos", x, 336, 14, COR_TEXTO);
  for (int i = 0; i < Partida.ATRIBUTOS.length; i++) {
    float y = 356 + i * 18;
    texto(Partida.ATRIBUTOS[i], x, y, 12, COR_TEXTO);
    textoDireita(anterior.atributo(i) + "/20 → " + pais.atributo(i) + "/20", x + W_PAINEL, y, 12, COR_TEXTO);
  }
  divisoria(441);
  texto("Decisão", x, 461, 15, COR_TEXTO);
  paragrafo(pais.decisao(), x, 472, W_PAINEL, 48, 13, COR_TEXTO);
  if (Double.isFinite(pais.pontos())) texto("Pontuação gulosa · " + decimal(pais.pontos()), x, 527, 12, COR_SUAVE);
  if (!pais.efeitos().isEmpty()) {
    texto("Disputas recebidas", x, 552, 14, COR_TEXTO);
    paragrafo(pais.efeitos(), x, 563, W_PAINEL, 73, 12, COR_TEXTO);
  }
}

void desenharEvolucao(Partida.Quadro quadro, int escolhido) {
  float x = X_PAINEL;
  Partida.Resumo pais = quadro.pais(escolhido);
  texto("Geração " + quadro.geracao() + " · Rodada " + quadro.rodada(), x, 185, 16, COR_TEXTO);
  texto(Evolucao.TAMANHO + " estratégias por país", x, 209, 13, COR_SUAVE);
  textoDireita(textoDominacao(quadro, escolhido), x + W_PAINEL, 209, 11, COR_SUAVE);
  divisoria(225);
  for (int i = 0; i < Evolucao.FOCOS.length; i++) {
    float y = 255 + 29 * i;
    texto(Evolucao.FOCOS[i], x, y, 14, COR_TEXTO);
    textoDireita(round((float) (100 * pais.estrategia().gene(i))) + "%", x + W_PAINEL, y, 14, COR_TEXTO);
  }
  texto("Melhor fitness", x, 366, 14, COR_TEXTO);
  textoDireita(Double.isFinite(pais.fitness()) ? decimal(pais.fitness()) : "Aguardando avaliação", x + W_PAINEL, 366, 13, COR_TEXTO);
  divisoria(389);
  paragrafo("A cada duas rodadas, as estratégias são testadas em cópias da partida. "
    + "A geração seguinte usa torneio de três, crossover uniforme, mutação e elitismo.", x, 405, W_PAINEL, 88, 13, COR_SUAVE);
  if (escolhido == partida.jogador && pais.regioes() > 0 && partida.vencedor() == -1) {
    paragrafo("Sua prioridade em jogo · " + Evolucao.FOCOS[focoJogador], x, 495, W_PAINEL, 47, 13, COR_TEXTO);
  }
}

String decimal(double valor) { return nf((float) valor, 0, 1); }

void desenharMenu() {
  botoes.clear();
  if (menu == 3) {
    ArrayList<Integer> vizinhos = new ArrayList<Integer>(grafo.vizinhos(regiaoFoco));
    vizinhos.sort(Comparator.comparingInt((Integer id) -> grafo.custo(regiaoFoco, id)).thenComparingInt(id -> id));
    float y = 314;
    painelMenu(y, 51 + 28 * vizinhos.size(), "Vizinhos · " + partida.nomeRegiao(regiaoFoco));
    for (int i = 0; i < vizinhos.size(); i++) {
      int id = vizinhos.get(i);
      String rotulo = partida.nomeRegiao(id) + "   ·   Custo " + grafo.custo(regiaoFoco, id);
      botao(X_PAINEL + 8, y + 38 + i * 28, W_PAINEL - 16, 24, rotulo, true, false, () -> {
        selecionarRegiao(id);
        menu = 0;
      });
    }
    return;
  }

  boolean escolhaJogador = menu == 1;
  int linhas = (paises.length + 1) / 2;
  float y = 87;
  painelMenu(y, 49 + linhas * 29, escolhaJogador ? "Iniciar partida como" : "Consultar país");
  for (int i = 0; i < paises.length; i++) {
    final int pais = i;
    float x = X_PAINEL + 8 + (i / linhas) * 162;
    float yy = y + 37 + (i % linhas) * 29;
    String nome = paises[i].dados.nome();
    if (!escolhaJogador && partida.quadro(rodadaVista).pais(i).derrotadoPor() != -1) nome += " · dominado";
    botao(x, yy, 157, 25, nome, true, i == (escolhaJogador ? partida.jogador : regiaoFoco / 2), () -> {
      if (escolhaJogador && podeEscolherPais()) iniciarPartida(pais);
      if (!escolhaJogador) selecionarRegiao(2 * pais);
      menu = 0;
    });
  }
}

void painelMenu(float y, float h, String titulo) {
  stroke(COR_LINHA);
  strokeWeight(1);
  fill(COR_FUNDO);
  rect(X_PAINEL, y, W_PAINEL, h, 3);
  texto(titulo, X_PAINEL + 8, y + 23, 13, COR_TEXTO);
  botao(X_PAINEL + W_PAINEL - 32, y + 6, 25, 23, "×", true, false, () -> menu = 0);
}
