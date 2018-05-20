class Rectangle extends Shape
{
    Rectangle()
    {
    }

    Rectangle(float x, float y, float w, float h)
    {
        set(x, y, w, h);
    }

    @Override
    void draw()
    {
        rect(x(), y(), w(), h());
    }

    @Override
    boolean isInside(float x, float y)
    {
        return this.x() <= x & x <= this.rx() &
               this.y() <= y & y <= this.ry();
    }

    boolean isInside(Rectangle r)
    {
        return this.x() <= r.x() & r.rx() <= this.rx() &
               this.y() <= r.y() & r.ry() <= this.ry();
    }

    boolean overlaps(Rectangle r)
    {
        return !(r.rx() < this.x() | this.rx() < r.x() |
                 r.ry() < this.y() | this.ry() < r.y());
    }

    Rectangle intersectWith(Rectangle r)
    {
        this.setFromSides(max(this.x(), r.x()),
                          max(this.y(), r.y()),
                          min(this.rx(), r.rx()),
                          min(this.ry(), r.ry()));
        return this;
    }

    Rectangle intersection(Rectangle r)
    {
        Rectangle res = new Rectangle();
        res.set(this);
        res.intersectWith(r);
        return res;
    }

    @Override
    float area()
    {
        return this.w() * this.h();
    }

    @Override
    float perimeter()
    {
        return (this.w() + this.h()) * 2;
    }
}
