import java.util.*;

ArrayList<Regiao> regioes = new ArrayList<Regiao>();
HashMap<String, Pais> paises = new HashMap<String, Pais>();
HashMap<Integer, HashSet<Integer>> grafo = new HashMap<Integer, HashSet<Integer>>();
HashMap<Integer, HashMap<Integer, Integer>> matriz = new HashMap<Integer, HashMap<Integer, Integer>>();
String[] nomes = {"Inglaterra", "Franca", "Espanha", "Alemanha"};
String jogador = "Inglaterra", aviso = "Selecione uma regiao sua e depois uma vizinha.";
int selecionada = -1, turno = 1, geracao = 1, acoes = 2;
boolean verGrafo = false, fim = false;

void setup() {
  size(1200, 720);
  surface.setTitle("Conflito de Fronteiras - Europa");
  textFont(createFont("Arial", 14));
  iniciar();
}

void iniciar() {
  regioes.clear(); paises.clear(); grafo.clear(); matriz.clear();
  int[] cores = {color(74, 143, 223), color(229, 152, 81), color(158, 110, 213), color(75, 177, 132)};
  for (int i = 0; i < 4; i++) paises.put(nomes[i], new Pais(nomes[i], cores[i]));
  regiao("York", 0, 220, 168, new float[]{192,148,205,121,226,134,246,164,236,207,211,207});
  regiao("Londres", 0, 227, 246, new float[]{211,207,239,206,261,251,243,286,211,277,202,248});
  regiao("Paris", 1, 399, 263, new float[]{352,235,394,211,442,236,455,279,425,319,373,307,350,275});
  regiao("Lyon", 1, 405, 348, new float[]{369,307,419,315,450,304,463,348,433,384,392,389,357,349});
  regiao("Madri", 2, 307, 432, new float[]{263,402,310,390,353,400,368,444,343,482,296,481,261,453});
  regiao("Barcelona", 2, 402, 432, new float[]{354,395,389,383,425,410,438,442,410,472,365,469});
  regiao("Berlim", 3, 529, 252, new float[]{476,224,509,205,539,221,568,227,580,265,548,296,503,285,471,257});
  regiao("Munique", 3, 525, 330, new float[]{478,284,507,293,549,298,573,324,551,358,516,374,479,342});
  conectar(0,1,1); conectar(1,2,3); conectar(2,3,1);
  conectar(3,4,2); conectar(3,5,1); conectar(4,5,1);
  conectar(2,6,2); conectar(3,7,1); conectar(6,7,1);
  for (String nome : nomes) {
    Pais p = paises.get(nome);
    for (int i = 0; i < 10; i++) p.pop.add(new Genoma(random(1), random(1), random(1)));
    avaliar(p);
  }
  jogador = nomes[0]; selecionada = -1; turno = 1; geracao = 1; acoes = 2; fim = false;
  aviso = "Escolha uma regiao sua, depois uma vizinha de outro pais.";
}

void regiao(String nome, int pais, float x, float y, float[] poligono) {
  int id = regioes.size();
  regioes.add(new Regiao(id, nome, nomes[pais], x, y, poligono));
  grafo.put(id, new HashSet<Integer>());
  matriz.put(id, new HashMap<Integer, Integer>());
}

void conectar(int a, int b, int custo) {
  grafo.get(a).add(b); grafo.get(b).add(a);
  matriz.get(a).put(b, custo); matriz.get(b).put(a, custo);
}

void draw() {
  background(18, 25, 40);
  fill(241); textSize(25); textAlign(LEFT);
  text("CONFLITO DE FRONTEIRAS", 28, 42);
  fill(150, 170, 193); textSize(12);
  text("EUROPA  |  ALGORITMOS E ESTRUTURAS DE DADOS", 28, 65);
  noStroke(); fill(31, 43, 61); rect(24, 86, 746, 538, 12);
  rect(785, 86, 389, 538, 12); rect(24, 638, 1150, 63, 12);
  desenharMapa();
  desenharPainel();
  fill(232); textSize(13); textAlign(LEFT); text(aviso, 40, 674);
}

void desenharMapa() {
  for (int y = 104; y < 610; y += 32) {
    stroke(65, 82, 104, 70); line(40, y, 752, y);
  }
  for (int x = 40; x < 752; x += 32) {
    stroke(65, 82, 104, 70); line(x, 103, x, 610);
  }
  fill(95, 124, 151); textSize(11); textAlign(CENTER);
  text("ATLANTICO", 103, 337); text("MAR DO NORTE", 303, 151);
  text("MEDITERRANEO", 492, 488);
  for (Regiao a : regioes) for (int id : grafo.get(a.id)) if (a.id < id) {
    Regiao b = regioes.get(id);
    if (verGrafo) {
      stroke(119, 201, 243, 160); strokeWeight(3); line(a.x, a.y, b.x, b.y);
      fill(230); textSize(11);
      text(matriz.get(a.id).get(id), (a.x+b.x)/2, (a.y+b.y)/2-9);
    } else if (a.id == 1 && id == 2) {
      stroke(99, 180, 222); strokeWeight(2);
      for (int i = 0; i < 12; i += 2) {
        float t = i / 12.0f, u = (i+1) / 12.0f;
        line(lerp(a.x,b.x,t),lerp(a.y,b.y,t),lerp(a.x,b.x,u),lerp(a.y,b.y,u));
      }
    }
  }
  for (Regiao r : regioes) {
    boolean vizinho = selecionada >= 0 && grafo.get(selecionada).contains(r.id);
    fill(paises.get(r.dono).cor);
    stroke(r.id == selecionada ? color(255,209,101) : vizinho ? color(144,211,240) : color(226,236,247));
    strokeWeight(r.id == selecionada ? 5 : vizinho ? 3 : 2);
    beginShape();
    for (int i = 0; i < r.poly.length; i += 2) vertex(r.poly[i], r.poly[i+1]);
    endShape(CLOSE);
    fill(255); textAlign(CENTER); textSize(14); text(r.nome, r.x, r.y+4);
    textSize(10); text("DEF " + r.defesa, r.x, r.y+19);
  }
  noStroke(); fill(167,190,210); textSize(12);
  text("INGLATERRA", 220, 105); text("FRANCA", 403, 198);
  text("ESPANHA", 315, 516); text("ALEMANHA", 525, 190);
  textAlign(LEFT); fill(150,170,191); textSize(11);
  text("F = mostrar grafo     Conexoes e pesos influenciam as disputas", 40, 603);
}

void desenharPainel() {
  Pais p = paises.get(jogador);
  textAlign(LEFT);
  fill(160,179,201); textSize(12); text("PAIS CONTROLADO (TECLAS 1-4)", 802, 118);
  fill(p.cor); noStroke(); ellipse(812,147,18,18);
  fill(245); textSize(20); text(p.nome, 829,153);
  fill(201,219,235); textSize(13);
  text("Recursos: "+p.recursos+"   Regioes: "+contar(jogador)+"   Acoes: "+acoes, 803,184);
  text("Turno: "+turno+"    Geracao: "+geracao+"    Populacao: 10",803,206);
  stroke(65,85,103); line(803,220,1155,220);
  fill(240); textSize(15); text("Melhor estrategia evolutiva",803,249);
  gene("Expansao",p.melhor.atk,276,color(232,158,97));
  gene("Protecao",p.melhor.def,313,color(92,171,220));
  gene("Economia",p.melhor.eco,350,color(86,189,144));
  fill(191,211,227); textSize(12); text("Fitness: "+nf(p.melhor.fit,0,2),803,381);
  fill(245); textSize(15); text("Historico evolutivo",803,411);
  grafico(p,803,422,350,65);
  fill(190,210,226); textSize(12);
  if (selecionada >= 0) {
    Regiao r = regioes.get(selecionada);
    text("Selecionada: "+r.nome+"  |  Dono: "+r.dono,803,514);
    text("Defesa: "+r.defesa+"  |  Vizinhos: "+grafo.get(r.id).size(),803,533);
  } else text("Selecione uma regiao no mapa.",803,520);
  botao(801,552,112,"TURNO",color(70,112,163));
  botao(920,552,113,"REFORCAR",color(78,129,105));
  botao(1040,552,116,"EVOLUIR",color(124,98,161));
  fill(165,185,206); textSize(11);
  text("ESP turno | R reforcar | G evoluir | N reiniciar",802,610);
}

void botao(int x,int y,int w,String txt,int cor) {
  noStroke(); fill(cor); rect(x,y,w,37,7);
  fill(255); textAlign(CENTER); textSize(12); text(txt,x+w/2,y+24); textAlign(LEFT);
}

void gene(String nome,float v,int y,int cor) {
  fill(200); textSize(12); text(nome,803,y+4);
  noStroke(); fill(52,67,85); rect(899,y-9,212,14,4);
  fill(cor); rect(899,y-9,212*v,14,4);
  fill(235); text(nf(v*100,0,0)+"%",1120,y+4);
}

void grafico(Pais p,int x,int y,int w,int h) {
  noStroke(); fill(22,32,48); rect(x,y,w,h,7);
  if(p.historico.size() < 2) {
    fill(145); textSize(11); text("Pressione G ou avance os turnos.",x+14,y+40); return;
  }
  float lo=9999,hi=-9999;
  for(float v:p.historico) { lo=min(lo,v); hi=max(hi,v); }
  stroke(p.cor); strokeWeight(2.5f); noFill(); beginShape();
  for(int i=0;i<p.historico.size();i++){
    float px=x+12+(w-24)*i/max(1.0f,p.historico.size()-1.0f);
    float py=map(p.historico.get(i),lo-0.5f,hi+0.5f,y+h-7,y+7);
    vertex(px,py);
  }
  endShape();
}

void mousePressed() {
  if(mouseY>=552 && mouseY<=589) {
    if(mouseX>=801 && mouseX<=913){ passarTurno(); return; }
    if(mouseX>=920 && mouseX<=1033){ reforcar(); return; }
    if(mouseX>=1040 && mouseX<=1156){ evoluir(); return; }
  }
  for(Regiao r:regioes) if(dentro(r,mouseX,mouseY)){ selecionar(r.id); return; }
}

boolean dentro(Regiao r,float x,float y) {
  boolean sim=false;
  int n=r.poly.length/2;
  for(int i=0,j=n-1;i<n;j=i++){
    float xi=r.poly[2*i],yi=r.poly[2*i+1];
    float xj=r.poly[2*j],yj=r.poly[2*j+1];
    if((yi>y)!=(yj>y) && x<(xj-xi)*(y-yi)/(yj-yi)+xi) sim=!sim;
  }
  return sim;
}

void selecionar(int id) {
  if(fim) return;
  Regiao r=regioes.get(id);
  if(selecionada<0 || r.dono.equals(jogador)){
    selecionada=id;
    aviso=r.dono.equals(jogador)?"Selecione uma regiao rival vizinha ou pressione R.":"Regiao de outro pais.";
    return;
  }
  disputar(selecionada,id,jogador,true);
}

boolean disputar(int origem,int destino,String nome,boolean usarAcao) {
  Regiao a=regioes.get(origem),b=regioes.get(destino);
  Pais p=paises.get(nome);
  if(fim || !a.dono.equals(nome) || b.dono.equals(nome) || !grafo.get(origem).contains(destino)){
    aviso="Escolha duas regioes conectadas de paises diferentes."; return false;
  }
  if((usarAcao && acoes<=0) || p.recursos<3){
    aviso="Acoes ou recursos insuficientes.";return false;
  }
  p.recursos-=3;
  float ofensiva=2+p.melhor.atk*8+random(5);
  float resistencia=2+paises.get(b.dono).melhor.def*7+b.defesa+matriz.get(origem).get(destino)+random(4);
  if(ofensiva>resistencia){
    String anterior=b.dono;
    b.dono=nome; b.defesa=1;
    aviso=nome+" conquistou "+b.nome+" de "+anterior+".";
  }else aviso=b.nome+" conseguiu resistir a "+nome+".";
  if(usarAcao) acoes--;
  for(String n:nomes) if(contar(n)==regioes.size()){fim=true;aviso=n+" venceu a partida! Aperte N para reiniciar.";}
  return true;
}

void reforcar() {
  if(fim || selecionada<0 || acoes<=0){aviso="Selecione uma regiao e tenha acoes.";return;}
  Regiao r=regioes.get(selecionada); Pais p=paises.get(jogador);
  if(!r.dono.equals(jogador)||r.defesa>=5||p.recursos<2){
    aviso="Requer regiao sua, defesa menor que 5 e 2 recursos.";return;
  }
  r.defesa++;p.recursos-=2;acoes--;aviso=r.nome+" recebeu reforcos.";
}

int contar(String nome) {
  int total=0;
  for(Regiao r:regioes) if(r.dono.equals(nome)) total++;
  return total;
}

void passarTurno() {
  if(fim) return;
  for(String nome:nomes){
    Pais p=paises.get(nome);
    p.recursos=min(24,p.recursos+contar(nome)*(1+round(p.melhor.eco*2)));
  }
  for(String nome:nomes) if(!nome.equals(jogador)) turnoIA(paises.get(nome));
  turno++;acoes=2;selecionada=-1;
  if(turno%2==1) evoluir();
  else if(!fim) aviso="Novo turno. Recursos recebidos e rivais agiram.";
}

void turnoIA(Pais p) {
  if(fim||contar(p.nome)==0)return;
  int origem=-1,destino=-1;
  float melhor=-999;
  for(Regiao a:regioes) if(a.dono.equals(p.nome))for(int id:grafo.get(a.id)){
    Regiao b=regioes.get(id);
    if(b.dono.equals(p.nome))continue;
    float nota=p.melhor.atk*6-b.defesa-matriz.get(a.id).get(id)+random(2);
    if(nota>melhor){melhor=nota;origem=a.id;destino=id;}
  }
  if(origem>=0 && p.recursos>=3 && random(1)<0.25f+p.melhor.atk*.7f){
    disputar(origem,destino,p.nome,false);
  }else for(Regiao r:regioes) if(r.dono.equals(p.nome)&&r.defesa<5&&p.recursos>=2){
    p.recursos-=2;r.defesa++;break;
  }
}

float fitness(Pais p,Genoma g) {
  int fronteiras=0;
  for(Regiao r:regioes)if(r.dono.equals(p.nome))
    for(int id:grafo.get(r.id))if(!regioes.get(id).dono.equals(p.nome))fronteiras++;
  return g.atk*(3+2*fronteiras)+g.def*(4+contar(p.nome))
    +g.eco*(4+24.0f/(p.recursos+4.0f))+2*min(g.atk,g.def);
}

void avaliar(Pais p) {
  p.melhor=null;
  for(Genoma g:p.pop){
    g.fit=fitness(p,g);
    if(p.melhor==null || g.fit>p.melhor.fit)p.melhor=g;
  }
  p.historico.add(p.melhor.fit);
  if(p.historico.size()>35)p.historico.remove(0);
}

Genoma torneio(Pais p) {
  Genoma melhor=null;
  for(int i=0;i<3;i++){
    Genoma g=p.pop.get((int)random(p.pop.size()));
    if(melhor==null || g.fit>melhor.fit)melhor=g;
  }
  return melhor;
}

Genoma crossover(Genoma a,Genoma b) {
  Genoma filho=new Genoma(random(1)<.5f?a.atk:b.atk,
    random(1)<.5f?a.def:b.def,random(1)<.5f?a.eco:b.eco);
  if(random(1)<.35f){
    int gene=(int)random(3);
    if(gene==0)filho.atk=max(.05f,filho.atk+random(-.2f,.2f));
    if(gene==1)filho.def=max(.05f,filho.def+random(-.2f,.2f));
    if(gene==2)filho.eco=max(.05f,filho.eco+random(-.2f,.2f));
    filho.normalizar();
  }
  return filho;
}

void evoluir() {
  if(fim)return;
  for(String nome:nomes){
    Pais p=paises.get(nome);
    for(Genoma g:p.pop)g.fit=fitness(p,g);
    Genoma elite=p.pop.get(0);
    for(Genoma g:p.pop)if(g.fit>elite.fit)elite=g;
    ArrayList<Genoma> nova=new ArrayList<Genoma>();
    nova.add(new Genoma(elite.atk,elite.def,elite.eco));
    while(nova.size()<10)nova.add(crossover(torneio(p),torneio(p)));
    p.pop=nova;avaliar(p);
  }
  geracao++;
  aviso="Nova geracao: fitness, selecao, crossover, mutacao e elitismo.";
}

void keyPressed() {
  if(key>='1'&&key<='4'){
    jogador=nomes[key-'1'];selecionada=-1;aviso="Controlando "+jogador+".";
  }else if(key==' ')passarTurno();
  else if(key=='r'||key=='R')reforcar();
  else if(key=='g'||key=='G')evoluir();
  else if(key=='f'||key=='F')verGrafo=!verGrafo;
  else if(key=='n'||key=='N')iniciar();
}

class Regiao {
  int id,defesa=2;
  String nome,dono;
  float x,y;
  float[] poly;
  Regiao(int i,String n,String d,float xx,float yy,float[] pp){
    id=i;nome=n;dono=d;x=xx;y=yy;poly=pp;
  }
}

class Pais {
  String nome;
  int cor,recursos=9;
  ArrayList<Genoma> pop=new ArrayList<Genoma>();
  ArrayList<Float> historico=new ArrayList<Float>();
  Genoma melhor;
  Pais(String n,int c){nome=n;cor=c;}
}

class Genoma {
  float atk,def,eco,fit;
  Genoma(float a,float d,float e){atk=a;def=d;eco=e;normalizar();}
  void normalizar(){
    atk=max(.05f,atk);def=max(.05f,def);eco=max(.05f,eco);
    float total=atk+def+eco;
    atk/=total;def/=total;eco/=total;
  }
}
