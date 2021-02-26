class Face {
  ArrayList<Edge> edges = new ArrayList<Edge>();
  int id = -1;

  PVector[] getVertexInOrder() {
    PVector[] verts = new PVector[edges.size()];

    for (int i=0, l= edges.size()-1; i<l; i++) {
      PVector a1 = edges.get(i).v1;
      PVector a2 = edges.get(i).v2;
      PVector b1 = edges.get(i+1).v1;
      PVector b2 = edges.get(i+1).v2;

      if (a1 == b1 || a1 == b2) {
        verts[i] = a2;
        verts[i+1] = a1;
      } else if (a2 == b1 || a2 == b2) {
        verts[i] = a1;
        verts[i+1] = a2;
      }
    }
    
    boolean vertNull = false;
    for(int i=0; i<verts.length; i++){
      if(verts[i] == null){
        vertNull = true;
        break;
      }
    }
    
    if(vertNull){
      for(int i=0; i<edges.size(); i++){
        println(edges.get(i));
        println(edges.get(i).v1);
        println(edges.get(i).v2);
      }
    }

    return verts;
  }

  PVector getNormal() {
    PVector[] verts = getVertexInOrder();
    PVector a = PVector.sub(verts[0], verts[1]);
    PVector b = PVector.sub(verts[2], verts[1]);  
    return a.cross(b).normalize();
  }

  float getPlaneDist(PVector p) {
    PVector[] verts = getVertexInOrder();
    PVector fromPlane = PVector.sub(p, verts[1]);
    PVector norm = getNormal();
    return fromPlane.dot(norm);
  }

  boolean isCoplanar(Face f) {
    PVector norm1 = getNormal();
    PVector norm2 = f.getNormal();
    if (norm1.dot(norm2) > 1.0-EPSILON) {
      return true;
    } else
      return false;
  }
}

class Edge {
  PVector v1;
  PVector v2;
  int id = -1;

  Edge() {
  }
  Edge(PVector _v1, PVector _v2) {
    v1 = _v1;
    v2 = _v2;
  }

  ArrayList<Face> faces = new ArrayList<Face>();

  ArrayList<Face> getNeighborFaces(Face ownerFace) {
    ArrayList<Face> toReturn = new ArrayList<Face>(faces);
    if(ownerFace == null)
      return toReturn;
    toReturn.remove(ownerFace);
    return toReturn;
  }

  void addFace(Face f) {
    if (!faces.contains(f)) {
      faces.add(f);
    }
  }

  float getDist(PVector p) {
    if(p == v1 || p == v2)
      return 0;
    PVector toP = PVector.sub(p, v1);
    PVector l = PVector.sub(v2, v1);
    PVector ul = l.copy().normalize();

    return PVector.sub(toP, ul.mult(toP.dot(ul))).mag();
  }

  boolean isCollinear(Edge e) {
    boolean v1Same = e.v1 == v1;
    boolean v2Same = e.v2 == v2;

    if (v1Same && v2Same)
      return true;

    if (!v1Same) {
      v1Same = isCollinear(e.v1);
    }
    if (!v2Same) {
      v2Same = isCollinear(e.v2);
    }

    if (v1Same && v2Same) { 
      return true;
    } else { 
      return false;
    }
  }

  boolean isCollinear(PVector p) {
    if (p == v1 || p == v2)
      return true;

    PVector a = PVector.sub(v1, v2);
    PVector b = PVector.sub(p, v2);

    float xt = a.x / b.x;
    float yt = a.y / b.y;
    float zt = a.z / b.z;

    if (floatEqual(xt, yt) && floatEqual(xt, zt) && floatEqual(yt, zt))
      return true;
    else
      return false;
  }
}
