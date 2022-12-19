// "Windy" simulation
// mouseclick = beginning
// By Jaroslav Trnka, 2020
// https://github.com/JaroslavTrnka1
// jaroslav_trnka@centrum.cz

// Inspired by and partially based on:
// Daniel Shiffman: The Coding Train
// and his Perlin noise videos

import java.util.Iterator;

int strana = 10;
int sirka;
int vyska;
ParticleSystem ps;
FlowField ff;

void setup() {
  size (1600, 1000);
  sirka = width/strana;
  vyska = height/strana;
  ff = new FlowField();
  background (255);
}

void draw () {
  background(0);
  //ff.display();
  //ff.update();
  if (ps != null) {
    for (int u = 0; u < ps.hustota; u++) {
    ps.addParticle();
    }
    ps.run();
  }
  
}

float sigmoid(float x){
  return (1.0/(1.0 + exp(-10.0 * (x - 0.5))));
}

float tanhextra(float x) {
  return (200*(1 - sq(2 * sigmoid(2*((x-50)/20)-1))));
}

void mousePressed() {
  ps = new ParticleSystem();
}

class FlowField {
  PVector [][] pole;
  float xoff, yoff, xnoi, ynoi;
  float silaPole = 0.2;
  float zmena = 0.0001; //pro update - proměnná rychlosti změny
  float roughness = 0.01; //jak rychle se mění noise mezi pozicemi pole

  FlowField() {
    xoff = 0;
    yoff = 10;
    xnoi = xoff;
    pole = new PVector[sirka][vyska];
    for (int i = 0; i < sirka; i++) {
      ynoi = yoff;
      for (int j = 0; j < vyska; j++) {
        pole [i][j] = PVector.fromAngle(map(noise(xnoi,ynoi), 0, 1, 0, TWO_PI));
        pole [i][j].mult(silaPole);
        ynoi += roughness;
      }
      xnoi += roughness;
    }
  }
  
  void update(){
    xoff += zmena;
    yoff += zmena;
    xnoi = xoff;
    for (int i = 0; i < sirka; i++) {
      ynoi = yoff;
      for (int j = 0; j < vyska; j++) {
        pole [i][j] = PVector.fromAngle(map(noise(xnoi,ynoi), 0, 1, 0, TWO_PI));
        pole [i][j].mult(silaPole);
        ynoi += roughness;
      }
      xnoi += roughness;
    }
  }
  
  void display() {
    for (int i = 0; i < sirka; i++) {
      for (int j = 0; j < vyska; j++) {
      pushMatrix();
      translate (i * strana, j * strana);
      //stroke(map(noise(xnoi,ynoi), 0, 1, 0, 255));
      line (0,0,strana*pole[i][j].x,strana*pole[i][j].y);
      popMatrix();
      }
    }
  }

}

class ParticleSystem {
  ArrayList<Particle> particles;
  int hustota = 10;

  ParticleSystem() {
    particles = new ArrayList();
  }

  void addParticle() {
    particles.add(new Particle());
  }

  void run() {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      p.run();
      if (p.isDead()) {
        it.remove();
      }
    }
  }
}


class Particle {
  PVector longtail;
  PVector velocity;
  PVector start;
  PVector head;
  PVector acceleration;
  float lifespan;
  float maxspeed = 2;

  Particle() {
    velocity = new PVector(0,0);
    start = new PVector (random(width), random(height));
    head = new PVector(start.x, start.y);
    lifespan = 100.0;
  }

  void run() {
    update();
    display();
  }

  void update() {
    acceleration = ff.pole[int(head.x/strana)][int(head.y/strana)];
    velocity.add(acceleration);
    if (velocity.mag() > maxspeed) {
      velocity.normalize();
      velocity.mult(maxspeed);
    }
    if (lifespan > 90) {
      head.add(velocity);
      longtail = new PVector(start.x, start.y);
    }
    else if (lifespan < 10) {
      longtail.add(velocity);
    }
    else {
      head.add(velocity);
      longtail = PVector.sub(head, velocity.mult(7));
    }
    if ((head.x > width) || (head.x < 0)) {lifespan = -1;}
    if ((head.y > height) || (head.y < 0)) {lifespan = -1;}
    lifespan -= 1.0;
  }

  void display() {
    stroke(0,0,255, (250-(4*abs(lifespan-40))));
    strokeWeight(2);
    fill(0);
    line(head.x, head.y, longtail.x, longtail.y);
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
