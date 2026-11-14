class DadosMapa {
  Partida.DadosPais dados;
  PShape forma;
  String nomeMapa;
  int cor;
  float rotuloX, rotuloY;
  float[] chamada;
  PVector[] centros = new PVector[2];
}

void carregarMapa() {
  JSONObject config = loadJSONObject("europa.json");
  mapaVetorial = loadShape("mapa.svg");
  JSONArray lista = config.getJSONArray("paises");
  paises = new DadosMapa[lista.size()];
  for (int i = 0; i < paises.length; i++) {
    JSONObject item = lista.getJSONObject(i);
    DadosMapa pais = new DadosMapa();
    String codigo = item.getString("codigo");
    pais.dados = new Partida.DadosPais(codigo, item.getString("nome"), item.getJSONArray("atributos").getIntArray());
    pais.nomeMapa = item.getString("nomeMapa");
    pais.cor = 0xff000000 | Integer.parseInt(item.getString("cor").substring(1), 16);
    pais.forma = mapaVetorial.getChild("pais_" + codigo);
    pais.rotuloX = item.getJSONArray("rotulo").getFloat(0);
    pais.rotuloY = item.getJSONArray("rotulo").getFloat(1);
    if (item.hasKey("chamada")) pais.chamada = item.getJSONArray("chamada").getFloatArray();
    for (int lado = 0; lado < 2; lado++) {
      JSONArray coordenadas = item.getJSONArray("centros").getJSONArray(lado);
      pais.centros[lado] = new PVector(coordenadas.getFloat(0), coordenadas.getFloat(1));
    }
    if (pais.forma == null) throw new IllegalStateException("País ausente no mapa: " + codigo);
    paises[i] = pais;
  }

  grafo = new Grafo(2 * paises.length);
  JSONArray ligacoes = config.getJSONArray("ligacoes");
  for (int i = 0; i < ligacoes.size(); i++) {
    JSONArray a = ligacoes.getJSONArray(i);
    grafo.conectar(a.getInt(0), a.getInt(1), a.getInt(2), a.getInt(3) == 1);
  }

  escalaMapa = min((float) W_MAPA / LARGURA_MAPA, (float) H_MAPA / ALTURA_MAPA);
  mapaX = X_MAPA + (W_MAPA - LARGURA_MAPA * escalaMapa) / 2;
  mapaY = Y_MAPA + (H_MAPA - ALTURA_MAPA * escalaMapa) / 2;
  mapaBase = createGraphics(2 * LARGURA_MAPA, 2 * ALTURA_MAPA, JAVA2D);

  // Máscara para os cliques
  mapaSelecao = createGraphics(LARGURA_MAPA, ALTURA_MAPA, JAVA2D);
  mapaSelecao.noSmooth();
  mapaSelecao.beginDraw();
  mapaSelecao.background(0xff000000);
  mapaSelecao.noStroke();
  for (int i = 0; i < paises.length; i++) {
    mapaSelecao.fill(0xff000000 | ((i + 1) << 16));
    paises[i].forma.disableStyle();
    mapaSelecao.shape(paises[i].forma);
    paises[i].forma.enableStyle();
  }
  mapaSelecao.endDraw();
  mapaSelecao.loadPixels();
}

PVector centroRegiao(int id) {
  return paises[id / 2].centros[id % 2];
}

void selecionarNoMapa(float xTela, float yTela) {
  float x = (xTela - mapaX) / escalaMapa, y = (yTela - mapaY) / escalaMapa;
  if (x < 0 || y < 0 || x >= LARGURA_MAPA || y >= ALTURA_MAPA) return;
  int selecionado = regiaoFoco / 2;
  PVector norte = paises[selecionado].centros[0], sul = paises[selecionado].centros[1];
  if (PVector.dist(norte, sul) >= 22) {
    if (dist(x, y, norte.x, norte.y) < 11) { selecionarRegiao(2 * selecionado); return; }
    if (dist(x, y, sul.x, sul.y) < 11) { selecionarRegiao(2 * selecionado + 1); return; }
  }
  int densidade = mapaSelecao.pixelDensity;
  int pixel = mapaSelecao.pixels[(int) (y * densidade) * mapaSelecao.pixelWidth + (int) (x * densidade)];
  int pais = ((pixel >>> 16) & 255) - 1;
  if (pais < 0 || pais >= paises.length) return;
  PVector n = paises[pais].centros[0], s = paises[pais].centros[1];
  selecionarRegiao(2 * pais + (dist(x, y, n.x, n.y) <= dist(x, y, s.x, s.y) ? 0 : 1));
}

void desenharMapa(Partida.Quadro quadro, Partida.Acao ataque) {
  atualizarCoresDoMapa(quadro);
  pushStyle();
  noStroke();
  fill(0xffd8e8ed);
  rect(X_MAPA, Y_MAPA, W_MAPA, H_MAPA);
  pushMatrix();
  translate(mapaX, mapaY);
  scale(escalaMapa);
  image(mapaBase, 0, 0, LARGURA_MAPA, ALTURA_MAPA);

  for (int i = 0; i < paises.length; i++) {
    int dono = quadro.dono(2 * i);
    if (dono == partida.jogador && partida.vencedor() == -1) {
      contornar(i, 0xff244e75, 2.0f);
    }
  }
  contornar(regiaoFoco / 2, 0xff382c24, 1.65f);

  for (Grafo.Aresta a : grafo.arestas()) {
    boolean adjacente = a.a() == regiaoFoco || a.b() == regiaoFoco;
    if (!grafoCompleto && (!adjacente || partida.vencedor() != -1)) continue;
    PVector p = centroRegiao(a.a()), q = centroRegiao(a.b());
    boolean rota = ataque != null && adjacente && (ataque.origem() == a.a() || ataque.origem() == a.b());
    stroke(rota ? 0xff263d49 : adjacente ? 0xc0415359 : 0x50516268);
    strokeWeight(rota ? 1.8f : 0.9f);
    if (a.maritima()) linhaTracejada(p, q);
    else line(p.x, p.y, q.x, q.y);
    if (rota || (adjacente && a.a() / 2 == a.b() / 2 && PVector.dist(p, q) > 42)) {
      custoNoMapa(a.custo(), (p.x + q.x) / 2, (p.y + q.y) / 2);
    }
  }

  for (DadosMapa pais : paises) {
    if (pais.chamada == null) continue;
    float[] l = pais.chamada;
    stroke(0xff51666b);
    strokeWeight(0.75f);
    line(l[0], l[1], l[2], l[3]);
    noStroke();
    fill(0xff51666b);
    circle(l[0], l[1], 3.3f);
  }
  int norte = (regiaoFoco / 2) * 2;
  if (quadro.dono(norte) == norte / 2 && partida.vencedor() == -1) {
    if (PVector.dist(centroRegiao(norte), centroRegiao(norte + 1)) >= 22) {
      desenharMarca(regiaoFoco == norte ? norte + 1 : norte);
    }
    desenharMarca(regiaoFoco);
  }

  textAlign(CENTER, CENTER);
  textSize(11);
  for (int i = 0; i < paises.length; i++) {
    DadosMapa pais = paises[i];
    int dono = quadro.dono(2 * i);
    String nome = paises[dono].nomeMapa;
    float x = pais.rotuloX, y = pais.rotuloY;
    if (dono != i && pais.chamada == null) {
      x = (pais.centros[0].x + pais.centros[1].x) / 2;
      y = (pais.centros[0].y + pais.centros[1].y) / 2;
    }
    fill(0xfffbfaf1);
    text(nome, x - 1, y);
    text(nome, x + 1, y);
    text(nome, x, y - 1);
    text(nome, x, y + 1);
    fill(0xff203137);
    text(nome, x, y);
  }
  popMatrix();

  noFill();
  stroke(COR_LINHA);
  strokeWeight(1);
  rect(X_MAPA, Y_MAPA, W_MAPA, H_MAPA);
  popStyle();
}

void atualizarCoresDoMapa(Partida.Quadro quadro) {
  if (quadroDoMapa == quadro) return;
  quadroDoMapa = quadro;
  mapaBase.beginDraw();
  mapaBase.background(0xffabd2ed);
  mapaBase.scale(2);
  mapaBase.shape(mapaVetorial);
  for (int i = 0; i < paises.length; i++) {
    int dono = quadro.dono(2 * i);
    if (dono == i) continue;
    PShape forma = paises[i].forma;
    forma.disableStyle();
    mapaBase.fill(paises[dono].cor);
    mapaBase.stroke(0xff6d7775);
    mapaBase.strokeWeight(0.8f);
    mapaBase.shape(forma);
    forma.enableStyle();
  }
  mapaBase.endDraw();
}

void contornar(int pais, int cor, float espessura) {
  PShape forma = paises[pais].forma;
  forma.disableStyle();
  noFill();
  stroke(cor);
  strokeWeight(espessura);
  shape(forma);
  forma.enableStyle();
}

void linhaTracejada(PVector a, PVector b) {
  float distancia = PVector.dist(a, b);
  for (float i = 0; i < distancia; i += 8) {
    float t1 = i / distancia, t2 = min(1, (i + 4) / distancia);
    line(lerp(a.x, b.x, t1), lerp(a.y, b.y, t1), lerp(a.x, b.x, t2), lerp(a.y, b.y, t2));
  }
}

void custoNoMapa(int custo, float x, float y) {
  pushStyle();
  fill(COR_FUNDO);
  stroke(COR_LINHA);
  strokeWeight(0.8f);
  rect(x - 7, y - 7, 14, 14, 2);
  fill(COR_TEXTO);
  textAlign(CENTER, CENTER);
  textSize(10);
  text(custo, x, y - 0.5f);
  popStyle();
}

void desenharMarca(int id) {
  PVector p = centroRegiao(id);
  stroke(id == regiaoFoco ? 0xfffdfbf0 : COR_DESTAQUE);
  strokeWeight(id == regiaoFoco ? 2 : 1);
  fill(COR_DESTAQUE);
  circle(p.x, p.y, 18);
  fill(0xffffffff);
  textAlign(CENTER, CENTER);
  textSize(10);
  text(id % 2 == 0 ? "N" : "S", p.x, p.y - 0.5f);
}
