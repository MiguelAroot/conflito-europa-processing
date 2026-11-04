import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

ArrayList<Pais> lista = new ArrayList<Pais>();
HashMap<String, Pais> paises = new HashMap<String, Pais>();
HashMap<String, HashSet<String>> grafo = new HashMap<String, HashSet<String>>();
HashMap<String, Integer> matriz = new HashMap<String, Integer>();

Pais escolhido = null;
String aviso = "Escolha um pais e depois um vizinho.";
int rodada = 1;

void setup() {
  size(840, 520);
  criarPais("Inglaterra", 160, 153, color(75, 145, 220), 4, 2);
  criarPais("França", 389, 218, color(240, 155, 68), 3, 3);
  criarPais("Espanha", 282, 373, color(160, 110, 200), 2, 4);
  criarPais("Alemanha", 646, 158, color(77, 175, 120), 4, 3);

  conectar("Inglaterra", "França", 3);
  conectar("Espanha", "França", 1);
  conectar("França", "Alemanha", 1);
}

void draw() {
  background(244, 247, 251);
  fill(30, 40, 55);
  textAlign(LEFT);
  textSize(24);
  text("Conflito de Fronteiras - Europa", 25, 38);
  textSize(13);
  text("Clique em dois paises ligados. Aperte C para testar o crossover.", 25, 63);
  text("Rodada: " + rodada, 720, 38);

  for (int i = 0; i < lista.size(); i++) {
    Pais a = lista.get(i);
    for (String nome : grafo.get(a.nome)) {
      Pais b = paises.get(nome);
      int j = lista.indexOf(b);
      if (i < j) {
        if (a.nome.equals("Inglaterra") || b.nome.equals("Inglaterra")) {
          stroke(70, 150, 205);
          strokeWeight(3);
          for (int passo = 0; passo < 20; passo += 2) {
            float t1 = passo / 20.0;
            float t2 = (passo + 1) / 20.0;
            line(lerp(a.x, b.x, t1), lerp(a.y, b.y, t1),
                 lerp(a.x, b.x, t2), lerp(a.y, b.y, t2));
          }
        } else {
          stroke(180, 190, 205);
          strokeWeight(4);
          line(a.x, a.y, b.x, b.y);
        }
      }
    }
  }

  for (Pais p : lista) {
    if (p == escolhido) {
      stroke(255, 200, 50);
      strokeWeight(5);
    } else {
      stroke(255);
      strokeWeight(3);
    }
    fill(paises.get(p.dono).cor);
    ellipse(p.x, p.y, 112, 112);
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(p.nome, p.x, p.y - 10);
    textSize(12);
    text("A: " + p.ataque + "  D: " + p.defesa, p.x, p.y + 11);
    textSize(10);
    text(p.dono, p.x, p.y + 27);
  }

  fill(30, 40, 55);
  textAlign(LEFT);
  textSize(13);
  text("A = ataque   D = defesa   Linha tracejada = passagem por mar", 25, 452);
  text(aviso, 25, 483);
}

void criarPais(String nome, int x, int y, int cor, int ataque, int defesa) {
  Pais p = new Pais(nome, x, y, cor, ataque, defesa);
  lista.add(p);
  paises.put(nome, p);
  grafo.put(nome, new HashSet<String>());
}

void conectar(String a, String b, int peso) {
  grafo.get(a).add(b);
  grafo.get(b).add(a);
  int i = lista.indexOf(paises.get(a));
  int j = lista.indexOf(paises.get(b));
  matriz.put(i + "," + j, peso);
  matriz.put(j + "," + i, peso);
}

void mousePressed() {
  for (Pais p : lista) {
    if (dist(mouseX, mouseY, p.x, p.y) < 56) {
      if (escolhido == null) {
        escolhido = p;
        aviso = "Agora escolha um pais vizinho de " + p.nome + ".";
      } else {
        disputar(escolhido, p);
        escolhido = null;
      }
      return;
    }
  }
}

void disputar(Pais a, Pais b) {
  if (a == b) {
    aviso = "Escolha dois paises diferentes.";
    return;
  }
  if (!grafo.get(a.nome).contains(b.nome)) {
    aviso = "Esses paises nao possuem uma ligacao direta.";
    return;
  }
  if (a.dono.equals(b.dono)) {
    aviso = "Esses paises ja estao no mesmo grupo.";
    return;
  }

  int i = lista.indexOf(a);
  int j = lista.indexOf(b);
  int peso = matriz.get(i + "," + j);
  float resultado = a.ataque + random(1, 5);
  float resistencia = b.defesa + peso + random(1, 4);

  if (resultado > resistencia) {
    b.dono = a.dono;
    aviso = a.nome + " venceu a disputa por " + b.nome + ".";
  } else {
    aviso = b.nome + " manteve o controle do territorio.";
  }
  rodada++;
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    Pais a = paises.get("Inglaterra");
    Pais b = paises.get("Espanha");
    Pais filho = paises.get("Alemanha");
    filho.ataque = a.ataque;
    filho.defesa = b.defesa;
    aviso = "Crossover: Alemanha recebeu A da Inglaterra e D da Espanha.";
  }
}

class Pais {
  String nome, dono;
  int x, y, cor, ataque, defesa;

  Pais(String nome, int x, int y, int cor, int ataque, int defesa) {
    this.nome = nome;
    this.dono = nome;
    this.x = x;
    this.y = y;
    this.cor = cor;
    this.ataque = ataque;
    this.defesa = defesa;
  }
}