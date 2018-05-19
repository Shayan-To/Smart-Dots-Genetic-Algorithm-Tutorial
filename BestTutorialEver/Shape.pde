abstract class Shape
{
  Shape set(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = max(w, 0);
    this.h = max(h, 0);
    return this;
  }

  Shape setFromSides(float x, float y, float rx, float ry)
  {
    set(x, y, rx - x, ry - y);
    return this;
  }

  Shape setFromCenterSize(float cx, float cy, float rw, float rh)
  {
    set(cx - rw, cy - rh, rw * 2, rh * 2);
    return this;
  }

  Shape setFromCenterSize(float cx, float cy, float r)
  {
    set(cx - r, cy - r, r * 2, r * 2);
    return this;
  }

  abstract void draw();
  abstract boolean isInside(float x, float y);
  abstract float area();
  abstract float perimeter();

  boolean isInside(PVector v)
  {
    return isInside(v.x, v.y);
  }

  float x()
  {
    return this.x;
  }

  float y()
  {
    return this.y;
  }

  float w()
  {
    return this.w;
  }

  float h()
  {
    return this.h;
  }

  float rx()
  {
    return this.x + this.w;
  }

  float ry()
  {
    return this.y + this.h;
  }
  
  float cx()
  {
    return this.x + this.w / 2;
  }
  
  float cy()
  {
    return this.y + this.h / 2;
  }

  PVector center()
  {
    return new PVector(this.cx(), this.cy());
  }

  PVector corner()
  {
    return new PVector(this.x, this.y);
  }

  PVector size()
  {
    return new PVector(this.w(), this.h());
  }

  private float x, y, w, h;
}
