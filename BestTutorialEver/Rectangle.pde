class Rectangle
{
  float x, y, w, h;

  Rectangle()
  {
  }

  Rectangle(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
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
    if (x < this.x | this.x + this.w < x |
        y < this.y | this.y + this.h < y)
    {
      return false;
    }
    return true;
  }

  boolean overlaps(Rectangle r)
  {
    if (r.x + r.w < this.x | this.x + this.w < r.x |
        r.y + r.h < this.y | this.y + this.h < r.y)
    {
      return false;
    }
    return true;
  }
}
