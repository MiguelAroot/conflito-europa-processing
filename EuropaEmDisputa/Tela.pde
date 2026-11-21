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
  texto(paises.length + " países  ·  " + grafo.tamanho + " regiões  ·  " + grafo.arestas().size() + " ligações", 18, 66, 12, COR_SUAVE);
  botao(500, 45, 110, 25, "Grafo (G)", true, grafoCompleto, () -> grafoCompleto = !grafoCompleto);
  botao(617, 45, 127, 25, telaCheia ? "Voltar à janela" : "Tela cheia (F11)", true, false, () -> alternarTelaCheia());
  texto("GISCO 2021 · © EuroGeographics pelos limites administrativos · Natural Earth", 18, 705, 11, COR_SUAVE);
  stroke(0xffc6cdc5);
  strokeWeight(1);
  line(754, 46, 754, 705);
}

void desenharPainel(Historico.Quadro quadro, Partida.Acao ataque) {
  int escolhido = regiaoFoco / 2;
  float x = X_PAINEL, w = W_PAINEL;
  int vencedor = partida.vencedor();
  texto("Você joga com " + paises[partida.jogador].dados.nome(), x, 71, 12, COR_SUAVE);
  if (podeEscolherPais()) {
    String rotulo = vencedor == -1 ? "Jogar como..." : "Nova partida";
    botao(x + 217, 53, 120, 25, rotulo, true, false, () -> menu = MENU_JOGADOR);
  }
  texto(paises[escolhido].dados.nome(), x, 107, 19, COR_TEXTO);
  botao(x + 229, 86, 108, 26, "Ver país...", true, false, () -> menu = MENU_PAIS);

  String[] nomesAbas = {"País", "Histórico", "Evolução", "Rotas"};
  divisoria(151);
  for (int i = 0; i < nomesAbas.length; i++) {
    final int indice = i;
    float esquerda = x + i * 84;
    Botao area = new Botao(esquerda, 120, 83, 32, true, () -> abrirAba(indice));
    botoes.add(area);
    boolean ativa = aba == i;
    if (ativa || area.contem(xNaTela(mouseX), yNaTela(mouseY))) {
      stroke(COR_DESTAQUE);
      strokeWeight(ativa ? 2 : 1);
      line(esquerda + 5, 151, esquerda + 78, 151);
    }
    textSize(13);
    texto(nomesAbas[i], esquerda + (83 - textWidth(nomesAbas[i])) / 2, 141, 13, ativa ? COR_DESTAQUE : COR_SUAVE);
  }

  if (aba == ABA_PAIS) desenharPartida(quadro, escolhido, ataque);
  if (aba == ABA_HISTORICO) desenharHistorico(quadro, escolhido);
  if (aba == ABA_EVOLUCAO) desenharEvolucao(quadro, escolhido);
  if (aba == ABA_ROTAS) desenharRotas(escolhido);

  divisoria(643);
  if (vencedor != -1) {
    texto("Vencedor · " + paises[vencedor].dados.nome(), x, 660, 15, COR_TEXTO);
  } else if (partida.quadro(partida.rodada()).pais(partida.jogador).regioes() == 0) {
    texto("Seu país foi dominado. Você está assistindo.", x, 660, 12, COR_SUAVE);
  } else if (planejada.tipo() == Partida.Tipo.PASSAR) {
    texto("Próxima ação: poupar recursos", x, 660, 12, COR_SUAVE);
  } else {
    paragrafo("Próxima ação: " + partida.descricao(planejada), x, 649, 261, 28, 12, COR_TEXTO);
    botao(x + 274, 650, 63, 21, "Limpar", true, false, () -> planejada = Partida.Acao.passar());
  }
  botao(x, 678, w, 29, vencedor == -1 ? "Próxima rodada" : "Partida encerrada", vencedor == -1, true, () -> avancar());
}

String textoDominacao(Historico.Quadro quadro, int escolhido) {
  int conquistador = quadro.pais(escolhido).derrotadoPor();
  if (conquistador == -1) return "";
  return "Dominado por " + paises[conquistador].dados.nome();
}

void desenharPartida(Historico.Quadro quadro, int escolhido, Partida.Acao ataque) {
  float x = X_PAINEL;
  Historico.Resumo pais = quadro.pais(escolhido);
  Historico.Resumo jogador = quadro.pais(partida.jogador);
  texto("PIB " + pais.pib() + "     Caixa " + pais.caixa() + "     Tropas " + pais.tropas(), x, 181, 16, COR_TEXTO);
  texto("Regiões " + pais.regioes() + "  /  Comércio com " + pais.parceiros() + " países  /  Renda " + pais.renda(), x, 204, 12, COR_SUAVE);

  divisoria(218);
  boolean comparacao = escolhido != partida.jogador;
  texto("Atributos", x, 239, 13, COR_TEXTO);
  if (comparacao) {
    textoDireita("País", x + 264, 239, 12, COR_SUAVE);
    textoDireita("Você", x + W_PAINEL, 239, 12, COR_SUAVE);
  } else {
    textoDireita("Nível", x + W_PAINEL, 239, 12, COR_SUAVE);
  }
  for (int i = 0; i < Partida.ATRIBUTOS.length; i++) {
    float y = 260 + i * 19;
    texto(Partida.ATRIBUTOS[i], x, y, 13, COR_TEXTO);
    textoDireita(pais.atributo(i) + "/20", x + (comparacao ? 264 : W_PAINEL), y, 13, COR_TEXTO);
    if (comparacao) textoDireita(jogador.atributo(i) + "/20", x + W_PAINEL, y, 13, COR_SUAVE);
  }

  regioesDoPais(escolhido, 352);
  botao(x + 168, 352, 169, 26, "Vizinhos e custos", true, false, () -> menu = MENU_VIZINHOS);
  String dominacao = textoDominacao(quadro, escolhido);
  if (dominacao.isEmpty()) {
    texto("Controle: " + paises[quadro.dono(regiaoFoco)].dados.nome(), x, 399, 13, COR_TEXTO);
    texto("Guarnição " + quadro.guarnicao(regiaoFoco) + "     Defesa " + decimal(quadro.defesa(regiaoFoco)), x, 418, 12, COR_SUAVE);
  } else {
    texto(dominacao, x, 399, 13, COR_TEXTO);
    texto("Controle atual: " + paises[quadro.dono(regiaoFoco)].dados.nome(), x, 418, 12, COR_SUAVE);
  }

  divisoria(432);
  texto("Ações do seu país", x, 455, 13, COR_TEXTO);
  textoDireita("Caixa " + jogador.caixa(), x + W_PAINEL, 455, 12, COR_SUAVE);
  boolean vivo = jogador.regioes() > 0 && partida.vencedor() == -1;
  botao(x, 466, W_PAINEL, 25, "Prioridade: " + Evolucao.FOCOS[focoJogador] + "  ▾", vivo, false, () -> menu = MENU_PRIORIDADE);
  botao(x, 498, 198, 27, Partida.ATRIBUTOS[atributo] + "  ▾", vivo, false, () -> menu = MENU_ATRIBUTO);
  Partida.Acao investir = Partida.Acao.investir(atributo);
  botao(x + 204, 498, 133, 27, "Investir (4)", partida.pode(investir), false, () -> planejar(investir));

  Partida.Acao recrutar = Partida.Acao.recrutar(regiaoFoco);
  Partida.Acao reforcar = Partida.Acao.reforcar(regiaoFoco);
  botao(x, 532, 108, 28, "Recrutar (6)", partida.pode(recrutar), false, () -> planejar(recrutar));
  botao(x + 113, 532, 108, 28, "Reforçar (3)", partida.pode(reforcar), false, () -> planejar(reforcar));
  botao(x + 226, 532, 111, 28, ataque == null ? "Atacar" : "Atacar (" + partida.custo(ataque) + ")",
    ataque != null, false, () -> planejar(ataque));

  if (ataque != null) {
    Combate.Previsao p = partida.prever(ataque);
    texto("Origem: " + partida.nomeRegiao(ataque.origem()), x, 582, 12, COR_TEXTO);
    texto("Vitória " + round((float) (100 * p.chance())) + "%  /  Baixas estimadas " + decimal(p.perdas()), x, 600, 12, COR_SUAVE);
    texto("Ataque " + decimal(p.ataque()) + "  ×  Defesa " + decimal(p.defesa()), x, 618, 12, COR_SUAVE);
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

void regioesDoPais(int pais, float y) {
  botao(X_PAINEL, y, 79, 26, "Norte", true, regiaoFoco % 2 == 0, () -> selecionarRegiao(pais * 2));
  botao(X_PAINEL + 84, y, 79, 26, "Sul", true, regiaoFoco % 2 == 1, () -> selecionarRegiao(pais * 2 + 1));
}

void desenharHistorico(Historico.Quadro quadro, int escolhido) {
  float x = X_PAINEL;
  botao(x, 165, 32, 27, "‹", rodadaVista > 0, false, () -> rodadaVista--);
  botao(x + 175, 165, 32, 27, "›", rodadaVista < partida.rodada(), false, () -> rodadaVista++);
  botao(x + 216, 165, 121, 27, "Rodada atual", rodadaVista != partida.rodada(), false, () -> rodadaVista = partida.rodada());
  texto("Rodada " + quadro.rodada() + " de " + partida.rodada(), x + 48, 183, 14, COR_TEXTO);
  Historico.Resumo pais = quadro.pais(escolhido);
  Historico.Resumo anterior = partida.quadro(max(0, quadro.rodada() - 1)).pais(escolhido);
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
  if (Double.isFinite(pais.pontos())) {
    texto("Pontuação gulosa · " + decimal(pais.pontos()), x, 527, 12, COR_SUAVE);
    botao(x + 247, 515, 90, 22, "Ver notas", true, false, () -> menu = MENU_NOTAS);
  }
  if (!pais.efeitos().isEmpty()) {
    texto("Disputas recebidas", x, 552, 14, COR_TEXTO);
    paragrafo(pais.efeitos(), x, 563, W_PAINEL, 73, 12, COR_TEXTO);
  }
}

void desenharEvolucao(Historico.Quadro quadro, int escolhido) {
  float x = X_PAINEL;
  Historico.Resumo pais = quadro.pais(escolhido);
  texto("Geração " + quadro.geracao(), x, 187, 16, COR_TEXTO);
  textoDireita(Evolucao.TAMANHO + " estratégias por país", x + W_PAINEL, 187, 12, COR_SUAVE);
  String dominacao = textoDominacao(quadro, escolhido);
  if (!dominacao.isEmpty()) texto(dominacao, x, 212, 12, COR_SUAVE);

  int rodadaAnterior = (quadro.geracao() - 2) * 2;
  Historico.Resumo antes = rodadaAnterior >= 0 ? partida.quadro(rodadaAnterior).pais(escolhido) : null;
  divisoria(230);
  if (antes != null) textoDireita("Anterior", x + 252, 252, 12, COR_SUAVE);
  textoDireita("Atual", x + W_PAINEL, 252, 12, COR_SUAVE);
  for (int i = 0; i < Evolucao.FOCOS.length; i++) {
    float y = 278 + 25 * i;
    texto(Evolucao.FOCOS[i], x, y, 14, COR_TEXTO);
    if (antes != null) textoDireita(round((float) (100 * antes.estrategia().gene(i))) + "%", x + 252, y, 14, COR_SUAVE);
    textoDireita(round((float) (100 * pais.estrategia().gene(i))) + "%", x + W_PAINEL, y, 14, COR_TEXTO);
  }
  texto("Melhor fitness", x, 359, 14, COR_TEXTO);
  if (antes != null) textoDireita(Double.isFinite(antes.fitness()) ? decimal(antes.fitness()) : "—", x + 252, 359, 13, COR_SUAVE);
  textoDireita(Double.isFinite(pais.fitness()) ? decimal(pais.fitness()) : "—", x + W_PAINEL, 359, 13, COR_TEXTO);
  divisoria(378);
  texto("As estratégias são avaliadas a cada duas rodadas.", x, 405, 12, COR_SUAVE);
  if (escolhido == partida.jogador && pais.regioes() > 0 && partida.vencedor() == -1) {
    texto("Sua prioridade: " + Evolucao.FOCOS[focoJogador], x, 434, 13, COR_TEXTO);
  }
}

void desenharRotas(int escolhido) {
  float x = X_PAINEL;
  texto("Menor rota (Dijkstra)", x, 185, 16, COR_TEXTO);
  regioesDoPais(escolhido, 199);
  texto("Origem", x, 251, 12, COR_SUAVE);
  texto(origemRota == -1 ? "Escolha no mapa" : partida.nomeRegiao(origemRota), x, 271, 14, COR_TEXTO);
  botao(x + 188, 243, 149, 29, "Fixar região como origem", origemRota != regiaoFoco, false, () -> fixarOrigemDaRota());
  texto("Destino", x, 296, 12, COR_SUAVE);
  texto(partida.nomeRegiao(regiaoFoco), x, 316, 14, COR_TEXTO);
  if (origemRota != -1) botao(x + 254, 290, 83, 28, "Limpar rota", true, false, () -> limparRota());
  divisoria(331);

  if (rotaConsultada == null || origemRota == regiaoFoco) {
    String instrucao = rotaConsultada == null ? "Selecione a origem e clique em Fixar região como origem."
      : "Selecione uma região diferente para ver a rota.";
    paragrafo(instrucao, x, 350, W_PAINEL, 50, 13, COR_SUAVE);
    return;
  }
  if (rotaConsultada.tamanho() == 0) {
    texto("Nenhum caminho entre essas regiões.", x, 364, 13, COR_SUAVE);
    return;
  }

  texto("Custo total: " + rotaConsultada.custo(), x, 359, 16, COR_TEXTO);
  textoDireita((rotaConsultada.tamanho() - 1) + " ligações", x + W_PAINEL, 359, 12, COR_SUAVE);
  texto("Região", x, 388, 12, COR_SUAVE);
  textoDireita("Custo da ligação", x + W_PAINEL, 388, 12, COR_SUAVE);
  int porPagina = 8;
  int inicio = paginaRota * porPagina;
  int fim = min(inicio + porPagina, rotaConsultada.tamanho());
  for (int i = inicio; i < fim; i++) {
    int id = rotaConsultada.regiao(i);
    float y = 410 + (i - inicio) * 22;
    texto((i + 1) + ". " + partida.nomeRegiao(id), x, y, 13, COR_TEXTO);
    String custo = i == 0 ? "—" : str(grafo.custo(rotaConsultada.regiao(i - 1), id));
    textoDireita(custo, x + W_PAINEL, y, 12, COR_SUAVE);
  }
  if (rotaConsultada.tamanho() > porPagina) {
    botao(x, 583, 31, 24, "‹", inicio > 0, false, () -> paginaRota--);
    texto((inicio + 1) + "–" + fim + " / " + rotaConsultada.tamanho(), x + 43, 600, 12, COR_SUAVE);
    botao(x + 116, 583, 31, 24, "›", fim < rotaConsultada.tamanho(), false, () -> paginaRota++);
  }
}

String decimal(double valor) { return nf((float) valor, 0, 1); }

void itemMenu(float x, float y, float largura, String nome, boolean selecionado, Runnable acao) {
  Botao area = new Botao(x, y, largura, 25, true, acao);
  botoes.add(area);
  if (selecionado || area.contem(xNaTela(mouseX), yNaTela(mouseY))) {
    noStroke();
    fill(0xffe2ebe9);
    rect(x, y, largura, 25);
  }
  textSize(12);
  if (textWidth(nome) > largura - 14) {
    do { nome = nome.substring(0, nome.length() - 1); } while (textWidth(nome + "…") > largura - 14);
    nome += "…";
  }
  texto(nome, x + 7, y + 17, 12, selecionado ? COR_DESTAQUE : COR_TEXTO);
}

void desenharMenu() {
  botoes.clear();
  if (menu == MENU_NOTAS) {
    desenharNotasDaDecisao();
    return;
  }
  if (menu == MENU_ATRIBUTO || menu == MENU_PRIORIDADE) {
    boolean prioridade = menu == MENU_PRIORIDADE;
    String[] opcoes = prioridade ? Evolucao.FOCOS : Partida.ATRIBUTOS;
    float y = 302;
    painelMenu(y, 43 + 27 * opcoes.length, prioridade ? "Escolher prioridade" : "Escolher atributo");
    for (int i = 0; i < opcoes.length; i++) {
      final int indice = i;
      itemMenu(X_PAINEL + 8, y + 34 + i * 27, W_PAINEL - 16, opcoes[i], i == (prioridade ? focoJogador : atributo), () -> {
        if (prioridade) focoJogador = indice;
        else atributo = indice;
        menu = 0;
      });
    }
    return;
  }
  if (menu == MENU_VIZINHOS) {
    ArrayList<Integer> vizinhos = new ArrayList<Integer>(grafo.vizinhos(regiaoFoco));
    vizinhos.sort(Comparator.comparingInt((Integer id) -> grafo.custo(regiaoFoco, id)).thenComparingInt(id -> id));
    float y = 314;
    painelMenu(y, 51 + 28 * vizinhos.size(), "Vizinhos · " + partida.nomeRegiao(regiaoFoco));
    for (int i = 0; i < vizinhos.size(); i++) {
      int id = vizinhos.get(i);
      String rotulo = partida.nomeRegiao(id) + "   ·   Custo " + grafo.custo(regiaoFoco, id);
      itemMenu(X_PAINEL + 8, y + 38 + i * 28, W_PAINEL - 16, rotulo, false, () -> {
        selecionarRegiao(id);
        menu = 0;
      });
    }
    return;
  }

  boolean escolhaJogador = menu == MENU_JOGADOR;
  int linhas = (paises.length + 1) / 2;
  float y = 87;
  painelMenu(y, 49 + linhas * 29, escolhaJogador ? "Iniciar partida como" : "Consultar país");
  for (int i = 0; i < paises.length; i++) {
    final int pais = i;
    float x = X_PAINEL + 8 + (i / linhas) * 162;
    float yy = y + 37 + (i % linhas) * 29;
    String nome = paises[i].dados.nome();
    if (!escolhaJogador && partida.quadro(rodadaVista).pais(i).derrotadoPor() != -1) nome += " · dominado";
    itemMenu(x, yy, 157, nome, i == (escolhaJogador ? partida.jogador : regiaoFoco / 2), () -> {
      if (escolhaJogador && podeEscolherPais()) iniciarPartida(pais);
      if (!escolhaJogador) selecionarRegiao(2 * pais);
      menu = 0;
    });
  }
}

void desenharNotasDaDecisao() {
  Historico.Resumo pais = partida.quadro(rodadaVista).pais(regiaoFoco / 2);
  float x = X_PAINEL, y = 252;
  painelMenu(y, 263, "Notas da decisão");
  texto(paises[regiaoFoco / 2].dados.nome() + " / Rodada " + rodadaVista, x + 10, y + 48, 12, COR_SUAVE);
  String[] nomes = {"Poupar", "Investir", "Recrutar", "Reforçar", "Atacar"};
  Partida.Tipo[] tipos = Partida.Tipo.values();
  for (int i = 0; i < tipos.length; i++) {
    float linha = y + 76 + 27 * i;
    boolean escolhida = pais.tipoEscolhido() == tipos[i];
    if (escolhida) {
      noStroke();
      fill(0xffe2ebe9);
      rect(x + 7, linha - 17, W_PAINEL - 14, 25);
    }
    double nota = pais.melhorNota(tipos[i]);
    texto((escolhida ? "* " : "  ") + nomes[i], x + 12, linha, 13, COR_TEXTO);
    textoDireita(Double.isFinite(nota) ? decimal(nota) : "Indisponível", x + W_PAINEL - 12, linha, 12, COR_SUAVE);
  }
  texto("* Ação escolhida", x + 12, y + 221, 12, COR_TEXTO);
  texto(pais.foiEmergencia() ? "Prioridade de retomada do conflito." : "Melhor nota de cada tipo de ação.", x + 12, y + 244, 12, COR_SUAVE);
}

void painelMenu(float y, float h, String titulo) {
  stroke(COR_LINHA);
  strokeWeight(1);
  fill(COR_FUNDO);
  rect(X_PAINEL, y, W_PAINEL, h, 3);
  texto(titulo, X_PAINEL + 8, y + 23, 13, COR_TEXTO);
  botao(X_PAINEL + W_PAINEL - 32, y + 6, 25, 23, "×", true, false, () -> menu = 0);
}
