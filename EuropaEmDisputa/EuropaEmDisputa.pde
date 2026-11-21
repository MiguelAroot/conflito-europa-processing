import java.util.ArrayList;
import java.util.Comparator;

final int LARGURA_MAPA = 620;
final int ALTURA_MAPA = 565;
final int LARGURA_TELA = 1120, ALTURA_TELA = 720;
final int X_MAPA = 18, Y_MAPA = 76, W_MAPA = 726, H_MAPA = 610;
final int X_PAINEL = 765, W_PAINEL = 337;
final int COR_FUNDO = 0xfff7f6f0, COR_TEXTO = 0xff26312e, COR_SUAVE = 0xff52615d;
final int COR_LINHA = 0xffa7b2aa, COR_DESTAQUE = 0xff284e62;
final int ABA_PAIS = 0, ABA_HISTORICO = 1, ABA_EVOLUCAO = 2, ABA_ROTAS = 3;
final int MENU_JOGADOR = 1, MENU_PAIS = 2, MENU_VIZINHOS = 3, MENU_ATRIBUTO = 4, MENU_PRIORIDADE = 5;
final int MENU_NOTAS = 6;

DadosMapa[] paises;
Grafo grafo;
Partida partida;
PShape mapaVetorial;
PGraphics mapaBase, mapaSelecao;
Historico.Quadro quadroDoMapa;
float mapaX, mapaY, escalaMapa;

int regiaoFoco, origemPreferida, rodadaVista, aba, menu;
int atributo = Partida.MERCADO, focoJogador = 2;
int origemRota = -1, paginaRota;
Grafo.Rota rotaConsultada;
boolean grafoCompleto;
Partida.Acao planejada = Partida.Acao.passar();
ArrayList<Botao> botoes = new ArrayList<Botao>();

public void settings() {
  java.awt.Dimension inicial = tamanhoInicialDaJanela();
  size(inicial.width, inicial.height, JAVA2D);
}

public void setup() {
  surface.setTitle("Europa em disputa");
  surface.setResizable(true);
  centralizarJanela();
  textFont(createFont("SansSerif", 14, true));
  frameRate(24);
  carregarMapa();
  int fr = 0;
  for (int i = 0; i < paises.length; i++) if (paises[i].dados.codigo().equals("FR")) fr = i;
  iniciarPartida(fr);
}

void iniciarPartida(int jogador) {
  Partida.DadosPais[] dados = new Partida.DadosPais[paises.length];
  for (int i = 0; i < paises.length; i++) dados[i] = paises[i].dados;
  partida = new Partida(dados, grafo, jogador, System.nanoTime());
  regiaoFoco = 2 * jogador;
  origemPreferida = regiaoFoco;
  rodadaVista = 0;
  aba = ABA_PAIS;
  menu = 0;
  atributo = Partida.MERCADO;
  focoJogador = 2;
  limparRota();
  planejada = Partida.Acao.passar();
}

boolean podeEscolherPais() {
  return partida.rodada() == 0 || partida.vencedor() != -1;
}

public void draw() {
  background(COR_FUNDO);
  atualizarEscalaDaTela();
  pushMatrix();
  translate(telaX, telaY);
  scale(escalaTela);
  botoes.clear();
  Historico.Quadro quadro = partida.quadro(rodadaVista);
  Partida.Acao ataque = aba == ABA_PAIS && rodadaVista == partida.rodada()
    ? partida.ataqueAoAlvo(regiaoFoco, origemPreferida, Evolucao.Estrategia.comFoco(focoJogador)) : null;
  desenharCabecalho();
  desenharMapa(quadro, ataque);
  desenharPainel(quadro, ataque);
  if (menu != 0) desenharMenu();
  popMatrix();
}

void selecionarRegiao(int id) {
  regiaoFoco = id;
  if (aba == ABA_PAIS && rodadaVista == partida.rodada() && partida.dono(id) == partida.jogador) origemPreferida = id;
  atualizarRota();
}

void abrirAba(int novaAba) {
  aba = novaAba;
  if (aba == ABA_PAIS) {
    rodadaVista = partida.rodada();
    if (partida.dono(regiaoFoco) == partida.jogador) origemPreferida = regiaoFoco;
  }
}

void fixarOrigemDaRota() {
  origemRota = regiaoFoco;
  atualizarRota();
}

void atualizarRota() {
  paginaRota = 0;
  rotaConsultada = origemRota == -1 ? null : grafo.menorRota(origemRota, regiaoFoco);
}

void limparRota() {
  origemRota = -1;
  atualizarRota();
}

void avancar() {
  partida.proximaRodada(planejada, Evolucao.Estrategia.comFoco(focoJogador));
  rodadaVista = partida.rodada();
  planejada = Partida.Acao.passar();
}

void planejar(Partida.Acao acao) {
  if (rodadaVista == partida.rodada() && acao != null && partida.pode(acao)) planejada = acao;
}

public void mousePressed() {
  float x = xNaTela(mouseX), y = yNaTela(mouseY);
  for (int i = botoes.size() - 1; i >= 0; i--) {
    Botao botao = botoes.get(i);
    if (botao.contem(x, y)) {
      if (botao.ativo) botao.acao.run();
      return;
    }
  }
  if (menu != 0) {
    menu = 0;
    return;
  }
  selecionarNoMapa(x, y);
}

public void keyPressed(processing.event.KeyEvent evento) {
  if (evento.isAutoRepeat()) return;
  if (keyCode == java.awt.event.KeyEvent.VK_F11) {
    alternarTelaCheia();
    return;
  }
  if (key == ESC && menu != 0) {
    key = 0;
    menu = 0;
  } else if (key == ESC && telaCheia) {
    key = 0;
    alternarTelaCheia();
  } else if (menu == 0 && (key == 'g' || key == 'G')) {
    grafoCompleto = !grafoCompleto;
  }
}
