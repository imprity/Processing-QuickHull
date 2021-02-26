class Poly {
  ArrayList<Face> faces = new ArrayList<Face>();
  ArrayList<Edge> edges = new ArrayList<Edge>();
  ArrayList<PVector> verts = new ArrayList<PVector>();

  void display() {
    for (Face f : faces) {
      beginShape();
      PVector[] verts = f.getVertexInOrder();
      for (int i=0, l= verts.length; i<l; i++) {
        vertex(verts[i].x, verts[i].y, verts[i].z);
      }
      endShape(CLOSE);
    }
  }

  void drawNormal(float l) {
    for (Face f : faces) {
      PVector norm = f.getNormal().mult(l);
      PVector[] verts = f.getVertexInOrder();
      norm.add(verts[1]);
      line(verts[1].x, verts[1].y, verts[1].z, norm.x, norm.y, norm.z);
    }
  }
}

Poly fromOBJ(String path) {
  Poly poly = new Poly();
  BufferedReader  reader = createReader(path);
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
      String[] pieces = split(line, " ");

      if (pieces[0].equals("v")) {

        PVector toPush = new PVector(parseFloat(pieces[1]), parseFloat(pieces[2]), parseFloat(pieces[3]));
        poly.verts.add(toPush);
      } else if (pieces[0].equals("f")) {

        Face f = new Face();
        f.edges = new ArrayList<Edge>();

        IntList indices = new IntList();
        for (int i=1; i<pieces.length; i++) {
          String[] crumbs = pieces[i].split("/");
          indices.push(parseInt(crumbs[0]) -1);
        }

        // reverse the vertex order since obj file reports them in counter clock wise order when we want them clock wise order
        indices.reverse();

        //add edges
        for (int i=0, l = indices.size()-1; i<l; i++) {
          int a = indices.get(i);
          int b = indices.get(i+1);
          int id = paringFunction(a, b);

          Edge e = findEdge(id, poly.edges);
          if (e == null) {
            e = new Edge();
            e.faces = new ArrayList<Face>();
            e.v1 = poly.verts.get(a); 
            e.v2 = poly.verts.get(b); 
            e.id = id;
            poly.edges.add(e);
          }
          e.addFace(f);
          f.edges.add(e);
        }

        // add the last edge
        int a = indices.get(indices.size()-1);
        int b = indices.get(0);
        int id = paringFunction(a, b);

        Edge e = findEdge(id, poly.edges);
        if (e == null) {
          e = new Edge();
          e.faces = new ArrayList<Face>();
          e.v1 = poly.verts.get(a); 
          e.v2 = poly.verts.get(b); 
          e.id = id;
          poly.edges.add(e);
        }
        e.addFace(f);
        f.edges.add(e);

        poly.faces.add(f);
      }
    }
    reader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  return poly;
}

Edge findEdge(int id, ArrayList<Edge> edgeList) {
  for (int i=0, l=edgeList.size(); i<l; i++) {
    Edge e = edgeList.get(i);
    if (id == e.id)
      return e;
  }
  return null;
}

int paringFunction(int a, int b) {
  float minN = min(a, b);
  float maxN = max(a, b);

  return round(0.5*(minN+maxN) * (minN + maxN+ 1.0f)+maxN);
}
