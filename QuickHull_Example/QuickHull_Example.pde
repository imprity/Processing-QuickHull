import peasy.*;
import java.util.*;

Poly objPoly = null;
Poly convexHull = null;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  //objPoly = fromOBJ("arrows.obj");
  objPoly = fromOBJ("susie.obj");
  //objPoly = fromOBJ("Ico.obj");

  for (PVector v : objPoly.verts) {
    v.mult(60);
  }

  cam = new PeasyCam(this, 400);
  
  convexHull = convexHull(objPoly.verts);
}

void draw() {
  background(100);
  lights();
  noStroke();
  fill(255);
  objPoly.display();
  
  fill(255,100);
  stroke(0);
  convexHull.display();

  stroke(0,0,255);
  strokeWeight(2);
  //objPoly.drawNormal(30);
  //convexHull.drawNormal(30);
}
