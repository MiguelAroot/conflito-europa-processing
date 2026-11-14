import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Frame;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsEnvironment;
import java.awt.Insets;
import java.awt.Rectangle;
import java.awt.Toolkit;
import processing.awt.PSurfaceAWT;

float telaX, telaY, escalaTela = 1;
boolean telaCheia;
Rectangle limitesDaJanela;
int estadoDaJanela;

Dimension tamanhoInicialDaJanela() {
  GraphicsConfiguration tela = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
  Rectangle util = areaUtil(tela);
  float escala = min(1, min((util.width - 48) / (float) LARGURA_TELA, (util.height - 72) / (float) ALTURA_TELA));
  return new Dimension(max(128, floor(LARGURA_TELA * escala)), max(128, floor(ALTURA_TELA * escala)));
}

Rectangle areaUtil(GraphicsConfiguration tela) {
  Rectangle monitor = tela.getBounds();
  Insets margem = Toolkit.getDefaultToolkit().getScreenInsets(tela);
  return new Rectangle(monitor.x + margem.left, monitor.y + margem.top,
    monitor.width - margem.left - margem.right, monitor.height - margem.top - margem.bottom);
}

void centralizarJanela() {
  executarNaJanela(() -> {
    Frame janela = canvasNativo().getFrame();
    Rectangle util = areaUtil(janela.getGraphicsConfiguration());
    janela.setLocation(util.x + (util.width - janela.getWidth()) / 2, util.y + (util.height - janela.getHeight()) / 2);
  });
}

void atualizarEscalaDaTela() {
  escalaTela = min(width / (float) LARGURA_TELA, height / (float) ALTURA_TELA);
  telaX = (width - LARGURA_TELA * escalaTela) / 2;
  telaY = (height - ALTURA_TELA * escalaTela) / 2;
}

float xNaTela(float x) { return (x - telaX) / escalaTela; }
float yNaTela(float y) { return (y - telaY) / escalaTela; }

void alternarTelaCheia() {
  executarNaJanela(() -> mudarModoDaJanela(canvasNativo()));
}

PSurfaceAWT.SmoothCanvas canvasNativo() {
  return (PSurfaceAWT.SmoothCanvas) surface.getNative();
}

void executarNaJanela(Runnable acao) {
  try {
    // Fila da janela
    if (EventQueue.isDispatchThread()) acao.run();
    else EventQueue.invokeAndWait(acao);
  } catch (InterruptedException erro) {
    Thread.currentThread().interrupt();
  } catch (java.lang.reflect.InvocationTargetException erro) {
    println("Falha ao ajustar a janela: " + erro.getCause());
  }
}

void mudarModoDaJanela(PSurfaceAWT.SmoothCanvas canvas) {
  Frame janela = canvas.getFrame();
  Rectangle monitor = janela.getGraphicsConfiguration().getBounds();
  Rectangle destino;
  if (telaCheia) {
    destino = limitesDaJanela;
  } else {
    limitesDaJanela = janela.getBounds();
    estadoDaJanela = janela.getExtendedState();
    destino = monitor;
  }

  // Troca a moldura
  janela.dispose();
  janela.setExtendedState(Frame.NORMAL);
  janela.setUndecorated(!telaCheia);
  janela.addNotify();
  Insets bordas = janela.getInsets();
  surface.setSize(destino.width - bordas.left - bordas.right, destino.height - bordas.top - bordas.bottom);
  janela.setLocation(destino.x, destino.y);
  janela.setVisible(true);
  telaCheia = !telaCheia;
  if (!telaCheia) janela.setExtendedState(estadoDaJanela);
  canvas.requestFocusInWindow();
}
