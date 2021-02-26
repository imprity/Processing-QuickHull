void removeDouble(ArrayList list) {
  int index = 0;
  while (true) {
    Object obj = list.get(index);
    for (int i = list.size()-1; i>index; i--) {
      if (list.get(i) == obj)
        list.remove(i);
    }
    index++;
    if (index >= list.size()-1)
      break;
  }
}

void reverseArr(ArrayList arr) {
  int size = arr.size();
  for (int i=0, l = size/2; i<l; i++) {
    Object temp = arr.get(i);
    arr.set(i, arr.get(size - i-1));
    arr.set(size - i-1, temp);
  }
}



boolean floatEqual(float a, float b) {
  if (abs(a-b) < EPSILON)
    return true;
  else
    return false;
}

class SortByX implements Comparator<PVector>
{
  public int compare(PVector a, PVector b) {
    if (a.x == b.x)
    {
      return 0;
    } 
    else if (a.x - b.x < 0) 
    {
      return -1;
    } 
    else 
    {
      return +1;
    }
  }
}

class SortByY implements Comparator<PVector>
{
  public int compare(PVector a, PVector b) {
    if (a.y == b.y)
    {
      return 0;
    } 
    else if (a.y - b.y < 0) 
    {
      return -1;
    } 
    else 
    {
      return +1;
    }
  }
}

class SortByZ implements Comparator<PVector>
{
  public int compare(PVector a, PVector b) {
    if (a.z == b.z)
    {
      return 0;
    } 
    else if (a.z - b.z < 0) 
    {
      return -1;
    } 
    else 
    {
      return +1;
    }
  }
}
