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
    return this.x <= x & x <= this.rx() &
           this.y <= y & y <= this.ry();
  }

  boolean isInside(Rectangle r)
  {
    return this.x <= r.x & r.rx() <= this.rx() &
           this.y <= r.y & r.ry() <= this.ry();
  }

  boolean overlaps(Rectangle r)
  {
    return !(r.rx() < this.x | this.rx() < r.x |
             r.ry() < this.y | this.ry() < r.y);
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

  float perimeter()
  {
    return (this.w + this.h) * 2;
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
