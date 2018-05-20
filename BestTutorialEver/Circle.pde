class Circle extends Shape
{
    Circle()
    {
    }

    Circle(float x, float y, float w, float h)
    {
        set(x, y, w, h);
    }

    @Override
    Shape set(float x, float y, float w, float h)
    {
        if (w != h)
        {
            throw new RuntimeException("Width and heigh of a circle must be equal.");
        }
        this.r = w / 2;
        super.set(x, y, w, h);
        return this;
    }

    @Override
    void draw()
    {
        ellipse(cx(), cy(), w(), h());
    }

    @Override
    boolean isInside(float x, float y)
    {
        return dist(this.cx(), this.cy(), x, y) <= this.r();
    }

    boolean isInside(Circle c)
    {
        return dist(this.cx(), this.cy(), c.cx(), c.cy()) <= this.r() - c.r();
    }

    boolean overlaps(Circle c)
    {
        return dist(this.cx(), this.cy(), c.cx(), c.cy()) <= this.r() + c.r();
    }

    @Override
    float area()
    {
        return PI * this.r() * this.r();
    }

    @Override
    float perimeter()
    {
        return 2 * PI * this.r();
    }

    float r()
    {
        return this.r;
    }

    private float r;
}
