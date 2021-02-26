Poly convexHull(ArrayList<PVector> originalPoints) {
  ArrayList<PVector> copyVs = new ArrayList<PVector>();

  for (PVector v : originalPoints) {
    copyVs.add(v.copy());
  }

  Poly convex = new Poly();
  PVector v1 = null;
  PVector v2 = null;

  boolean foundLine = false;

  for (int i=0; i<3; i++) {
    switch(i) {
    case 0:
      {        
        copyVs.sort(new SortByX()); 
        break;
      }
    case 1:
      {        
        copyVs.sort(new SortByY());        
        break;
      }
    case 2:
      {
        copyVs.sort(new SortByZ());
        break;
      }
    }
    v1 = copyVs.get(0);
    v2 = copyVs.get(copyVs.size()-1);

    if (PVector.sub(v1, v2).magSq() > 0) {
      foundLine = true;
      break;
    }
  }

  if (!foundLine) {
    throw new Error("looks line all your verts are on one plane");
  }

  PVector v3 = null;

  float maxDist = -1;
  Edge tempE = new Edge(v1, v2);

  for (PVector v : copyVs) {
    float d = tempE.getDist(v);
    if (d > maxDist) {
      maxDist = d;
      v3 = v;
    }
  }

  if (maxDist <=0) {
    throw new Error("looks line all your verts are on one plane");
  }

  Edge te1 = new Edge(v1, v2);
  Edge te2 = new Edge(v2, v3);
  Edge te3 = new Edge(v3, v1);

  Face tempF = new Face();

  tempF.edges.add(te1);
  tempF.edges.add(te2);
  tempF.edges.add(te3);

  PVector v4 = null; 
  maxDist = -1;
  for (PVector v : copyVs) {
    float d = abs(tempF.getPlaneDist(v));
    if (d > maxDist) {
      maxDist = d;
      v4 =v;
    }
  }

  if (maxDist <=0) {
    throw new Error("looks line all your verts are on one plane");
  }

  convex.verts.add(v1);
  convex.verts.add(v2);
  convex.verts.add(v3);
  convex.verts.add(v4);

  Face[] fs = new Face[4];
  Edge[] es = new Edge[6];

  for (int i=0; i<4; i++)
    fs[i] = new Face();
  for (int i=0; i<6; i++)
    es[i] = new Edge();

  es[0].v1 = convex.verts.get(0);
  es[0].v2 = convex.verts.get(1);

  es[1].v1 = convex.verts.get(1);
  es[1].v2 = convex.verts.get(2);

  es[2].v1 = convex.verts.get(2);
  es[2].v2 = convex.verts.get(0);

  es[3].v1 = convex.verts.get(2);
  es[3].v2 = convex.verts.get(3);

  es[4].v1 = convex.verts.get(3);
  es[4].v2 = convex.verts.get(0);

  es[5].v1 = convex.verts.get(3);
  es[5].v2 = convex.verts.get(1);

  // add face 0
  fs[0].edges.add(es[0]);
  fs[0].edges.add(es[1]); 
  fs[0].edges.add(es[2]);

  es[0].faces.add(fs[0]);
  es[1].faces.add(fs[0]);
  es[2].faces.add(fs[0]);

  // add face 1
  fs[1].edges.add(es[2]);
  fs[1].edges.add(es[3]); 
  fs[1].edges.add(es[4]);

  es[2].faces.add(fs[1]);
  es[3].faces.add(fs[1]);
  es[4].faces.add(fs[1]);

  // add face 2
  fs[2].edges.add(es[3]);
  fs[2].edges.add(es[1]); 
  fs[2].edges.add(es[5]);

  es[3].faces.add(fs[2]);
  es[1].faces.add(fs[2]);
  es[5].faces.add(fs[2]);

  // add face 3
  fs[3].edges.add(es[5]);
  fs[3].edges.add(es[0]); 
  fs[3].edges.add(es[4]);

  es[5].faces.add(fs[3]);
  es[0].faces.add(fs[3]);
  es[4].faces.add(fs[3]);

  if (fs[0].getPlaneDist(convex.verts.get(3)) >0) {

    println("reversed");
    for (Face f : fs) {
      Edge temp = f.edges.get(2);
      f.edges.set(2, f.edges.get(0));
      f.edges.set(0, temp);
    }
  }

  for (int i=0; i<4; i++)
    convex.faces.add(fs[i]);
  for (int i=0; i<6; i++)
    convex.edges.add(es[i]);

  boolean noOutside = false;
  while (!noOutside) {
    for (int i=copyVs.size()-1; i >=0; i--) {
      if (convex.verts.contains(copyVs.get(i)))
        copyVs.remove(i);
    }

    ArrayList<Face> fToAdd = new ArrayList<Face>();
    ArrayList<Edge> eToAdd = new ArrayList<Edge>();

    ArrayList<Face> fToRemove = new ArrayList<Face>();
    ArrayList<Edge> eToRemove = new ArrayList<Edge>();

    ArrayList<PVector> outsideVert = new ArrayList<PVector>();

    noOutside = true;
    Face currF = new Face();
    for (int i= convex.faces.size()-1; i >=0; i--) {
      currF = convex.faces.get(i);
      for (int j=0, l = copyVs.size(); j<l; j++) {
        addToOutSide(copyVs.get(j), currF, outsideVert);
      }
      if (outsideVert.size() >0) {
        noOutside = false;
        break;
      }
    }

    if (!noOutside) {

      maxDist = -1;
      PVector eye = null;

      for (int i=0, l=outsideVert.size(); i<l; i++) {
        PVector v  = outsideVert.get(i);
        float d = currF.getPlaneDist(v);
        if (d > maxDist) {
          eye = v;
          maxDist = d;
        }
      }

      //build cone
      ArrayList<Face> coneFace = new ArrayList<Face>();

      ArrayList<Edge> horizonEdge = new ArrayList<Edge>();
      ArrayList<Edge> crossedEdge = new ArrayList<Edge>();

      getHorizonEdge(eye, crossedEdge, null, currF, horizonEdge, fToRemove);

      removeDouble(horizonEdge);

      for (Edge toRemove : crossedEdge) {
        eToRemove.add(toRemove);
      }

      Face temp = new Face();
      temp.edges = new ArrayList<Edge>();
      temp.edges.addAll(horizonEdge);
      PVector[] verts = temp.getVertexInOrder();

      for (int i=0; i<verts.length; i++) {
        Edge toAdd = new Edge();
        toAdd.v1 = eye;
        toAdd.v2 = verts[i];
        eToAdd.add(toAdd);
      }

      for (int i=0, l = horizonEdge.size()-1; i<l; i++) {
        Face toAdd = new Face();
        toAdd.edges = new ArrayList<Edge>();
        toAdd.edges.add(eToAdd.get(i));
        toAdd.edges.add(horizonEdge.get(i));
        toAdd.edges.add(eToAdd.get(i+1));

        eToAdd.get(i).faces.add(toAdd);
        horizonEdge.get(i).faces.add(toAdd);
        eToAdd.get(i+1).faces.add(toAdd);

        fToAdd.add(toAdd);
        coneFace.add(toAdd);
      }

      Face lastFace = new Face();
      lastFace.edges = new ArrayList<Edge>();
      lastFace.edges.add(eToAdd.get(eToAdd.size()-1));
      lastFace.edges.add(horizonEdge.get(horizonEdge.size()-1));
      lastFace.edges.add(eToAdd.get(0));

      eToAdd.get(eToAdd.size()-1).faces.add(lastFace);
      horizonEdge.get(horizonEdge.size()-1).faces.add(lastFace);
      eToAdd.get(0).faces.add(lastFace);

      fToAdd.add(lastFace);
      coneFace.add(lastFace);

      for (int i= 0, l=fToAdd.size(); i<l; i++) {
        Edge between = horizonEdge.get(i);
        ArrayList<Face> neighbor = between.getNeighborFaces(fToAdd.get(i));

        Face mf = null;
        Face otherF = null;
        for (Face f : neighbor) {
          if (fToRemove.contains(f)) {
            continue;
          }
          otherF = f;
          mf = mergeFace(fToAdd.get(i), otherF, between);
          if (mf != null)
            break;
        }
        if (mf != null) {
          fToRemove.add(fToAdd.get(i));
          eToRemove.add(between);
          fToRemove.add(otherF);
          fToAdd.add(mf);
          coneFace.set(i, mf);
        }
      }

      cleanUp(convex, eToRemove, fToRemove, eToAdd, fToAdd);

      eToAdd.clear();
      fToAdd.clear();
      eToRemove.clear();
      fToRemove.clear();
      
      Face prevFace = coneFace.get(coneFace.size()-1);
      
      for (int i=0, l = coneFace.size(); i<l; i ++) {
        Face nextFace = coneFace.get(i);
        
        Edge between = findSharingEdge(prevFace, nextFace);
        
        Face mf = mergeFace(prevFace, nextFace, between);
        
        if(mf!= null){
          eToRemove.add(between);
          fToRemove.add(prevFace);
          fToRemove.add(nextFace);
          
          fToAdd.add(mf);
          
          prevFace = mf;
        }
        else{
          prevFace = nextFace;
        }
      }
      
      cleanUp(convex, eToRemove, fToRemove, eToAdd, fToAdd);
    }
  }


  return convex;
}

void cleanUp(Poly poly, ArrayList<Edge> eToRemove, ArrayList<Face> fToRemove, ArrayList<Edge> eToAdd, ArrayList<Face> fToAdd) {
  poly.edges.addAll(eToAdd);
  poly.faces.addAll(fToAdd);

  for (Edge e : poly.edges) {
    for (int i= e.faces.size()-1; i>=0; i--) {
      if (fToRemove.contains(e.faces.get(i)))
        e.faces.remove(i);
    }
  }

  for (Face f : poly.faces) {
    for (int i= f.edges.size()-1; i>=0; i--) {
      if (eToRemove.contains(f.edges.get(i)))
        f.edges.remove(i);
    }
  }

  poly.faces.removeAll(fToRemove);
  poly.edges.removeAll(eToRemove);

  for (Edge e : poly.edges) {
    if (!poly.verts.contains(e.v1))
      poly.verts.add(e.v1);
    if (!poly.verts.contains(e.v2))
      poly.verts.add(e.v2);
  }
}

void addToOutSide(PVector v, Face f, ArrayList<PVector> outsideList) {
  // if vertex is one of the face's return
  for (Edge e : f.edges) {
    if (v == e.v1 || v == e.v2)
      return;
  }

  float dist = f.getPlaneDist(v);

  if (dist > 0 && !outsideList.contains(v))
    outsideList.add(v);
}

Edge findSharingEdge(Face f1, Face f2) {
  for (Edge e1 : f1.edges) {
    for (Edge e2 : f2.edges) {
      if (e1 == e2) {
        return e1;
      }
    }
  }
  return null;
}

Face mergeFace(Face f1, Face f2, Edge between) {
  if (!f1.isCoplanar(f2))
    return null;

  println("merging");
  Face toReturn = new Face();

  int startIndex = -1;

  for (int i=0, l= f1.edges.size(); i<l; i++) {
    if (between == f1.edges.get(i)) {
      startIndex = i;
      break;
    }
  }

  int index = startIndex;
  while (true) {
    index++;
    if (index >= f1.edges.size())
      index = 0;
    if (index == startIndex)
      break;
    toReturn.edges.add(f1.edges.get(index));
    f1.edges.get(index).faces.add(toReturn);
  }

  startIndex = -1;

  for (int i=0, l= f2.edges.size(); i<l; i++) {
    if (between == f2.edges.get(i)) {
      startIndex = i;
      break;
    }
  }

  index = startIndex;

  while (true) {
    index++;
    if (index >= f2.edges.size())
      index = 0;
    if (index == startIndex)
      break;
    toReturn.edges.add(f2.edges.get(index));
    f2.edges.get(index).faces.add(toReturn);
  }

  toReturn.edges.remove(between);

  return toReturn;
}

void getHorizonEdge(PVector eye, ArrayList<Edge> crossedEdges, Edge cameFrome, Face currFace, ArrayList<Edge> horizons, ArrayList<Face> facesToRemove) {
  facesToRemove.add(currFace);
  int startIndex = -1;

  if (cameFrome == null) {
    startIndex = 0;
  } else {

    for (int i=0; i<currFace.edges.size(); i++) {
      if (cameFrome == currFace.edges.get(i))
        startIndex = i;
    }

    if (startIndex == -1)
      throw new Error("couldn't find starting edge");
  }

  int currEdgeIndex = startIndex;

  boolean breakLater = false;
  while (true && !breakLater) {
    //loop around the edge
    if (currEdgeIndex < currFace.edges.size()-1) {
      currEdgeIndex ++;
    } else {
      currEdgeIndex = 0;
    }

    if (currEdgeIndex == startIndex) {
      // if it looped back to the starting Point then if the edge it came from is null include starting point
      if (cameFrome == null) {
        breakLater = true;
      } else {
        break;
      }
    }

    Edge currE = currFace.edges.get(currEdgeIndex);

    if (crossedEdges.contains(currE)) {
      continue;
    }

    ArrayList<Face> neighbors = currE.getNeighborFaces(currFace);

    for (int i=neighbors.size()-1; i>=0; i--) {
      PVector norm = neighbors.get(i).getNormal();
      PVector toEye = PVector.sub(eye, neighbors.get(i).edges.get(0).v1);
      if (norm.dot(toEye) < 0) {
        neighbors.remove(i);
      }
    }

    if (neighbors.size() == 0 ) {
      horizons.add(currE);
    } else if (neighbors.size()!= 0) {
      crossedEdges.add(currE);
      for (Face f : neighbors) {
        facesToRemove.add(f);
        getHorizonEdge(eye, crossedEdges, currE, f, horizons, facesToRemove);
      }
    }
  }
}
