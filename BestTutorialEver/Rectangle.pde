class Rectangle
{
  float x, y, w, h;

  Rectangle()
  {
  }

  Rectangle(float x, float y, float w, float h)
  {
    set(x, y, w, h);
  }

  void set(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = max(w, 0);
    this.h = max(h, 0);
  }

  void setFromSides(float x, float y, float rx, float ry)
  {
    set(x, y, rx - x, ry - y);
  }

  void draw()
  {
    rect(x, y, w, h);
  }

  boolean isInside(PVector v)
  {
    return isInside(v.x, v.y);
  }

  boolean isInside(float x, float y)
  {
    if (x < this.x | this.rx() < x |
        y < this.y | this.ry() < y)
    {
      return false;
    }
    return true;
  }

  boolean overlaps(Rectangle r)
  {
    if (r.rx() < this.x | this.rx() < r.x |
        r.ry() < this.y | this.ry() < r.y)
    {
      return false;
    }
    return true;
  }

  Rectangle intersection(Rectangle r)
  {
    Rectangle res = new Rectangle();
    res.setFromSides(max(this.x, r.x),
                     max(this.y, r.y),
                     min(this.rx(), r.rx()),
                     min(this.ry(), r.ry()));
    return res;
  }

  float area()
  {
    return this.w * this.h;
  }

  float rx()
  {
    return this.x + this.w;
  }

  float ry()
  {
    return this.y + this.h;
  }
}
