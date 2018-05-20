class World
{
    final int brainSize = 1000;
    final Rectangle screenRect = new Rectangle(2, 2, width - 4, height - 4);
    final Circle goal  = (Circle) new Circle().setFromCenterSize(400, 10, 5);
    final PVector goalCenter = goal.center();
    final PVector startPoint = new PVector(screenRect.w() / 2, screenRect.h() - 10);

    final Rectangle goalMarginedRect = (Rectangle) new Rectangle().setFromCenterSize(goal.cx(), goal.cy(), 50);
    final Rectangle startMarginedRect = (Rectangle) new Rectangle().setFromCenterSize(startPoint.x, startPoint.y, 50);
    final int obstacleAreaMargin = 5;
    final int obstacleMinSize = 50;
    final int obstacleMaxSize = 200;
    final Rectangle obstacleAreaRect = new Rectangle(screenRect.x() + obstacleAreaMargin, screenRect.y() + obstacleAreaMargin,
                                                     screenRect.w() - obstacleAreaMargin * 2, screenRect.h() - obstacleAreaMargin * 2);

    final float stepCountingMinRadius = 75;
    final Circle stepCountingMinArea = (Circle) new Circle().setFromCenterSize(goal.cx(), goal.cy(), stepCountingMinRadius);
    final float stepCountingMaxRadius = 150;
    final Circle stepCountingMaxArea = (Circle) new Circle().setFromCenterSize(goal.cx(), goal.cy(), stepCountingMaxRadius);

    final float forbiddenAreaRadius = 50;
    final float previousPositionsForbiddenRadius = 5;
    final Circle forbiddenAreasForbiddenCircle = stepCountingMaxArea; // set it to stepCountingMaxArea so we don't have to have a separate representation.

    final Circle currentPreviousPositionsCircle = new Circle();
    final Circle currentPreviousPositionsForbiddenCircle = new Circle();

    Dot[] dots;
    Rectangle[] obstacles;
    final java.util.ArrayList<Circle> forbiddenAreas = new java.util.ArrayList<Circle>();

    final java.util.ArrayList<PVector> previousBestPositions = new java.util.ArrayList<PVector>();

    float fitnessSum;
    float averageStep = 300;
    float averageDistance = 300;
    int gen = 0;

    World(int dotsCount, int obstaclesCount)
    {
        dots = new Dot[dotsCount];
        obstacles = new Rectangle[obstaclesCount];
    }

    void init()
    {
        for (int i = 0; i < this.dots.length; i++)
        {
            Dot t = new Dot(this, brainSize);
            t.brain.randomize();
            this.dots[i] = t;
        }

        for (int i = 0; i < this.obstacles.length; i++)
        {
            float w = random(obstacleMaxSize - obstacleMinSize) + obstacleMinSize;
            float h = random(obstacleMaxSize - obstacleMinSize) + obstacleMinSize;
            Rectangle o = new Rectangle(random(obstacleAreaRect.w() - w) + obstacleAreaRect.x(),
                                        random(obstacleAreaRect.h() - h) + obstacleAreaRect.y(),
                                        w, h);

            float occupiedArea = 0;
            for (int j = 0; j < i; j++)
            {
                occupiedArea += obstacles[j].intersection(o).area();
            }
            if (goalMarginedRect.overlaps(o) | startMarginedRect.overlaps(o) | occupiedArea / o.area() > 0.2)
            {
                i--;
                continue;
            }

            this.obstacles[i] = o;
        }
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // show all dots
    void show()
    {
        fill(0, 255, 0, 20);
        stepCountingMaxArea.draw();
        fill(0, 255, 0, 20);
        stepCountingMinArea.draw();

        fill(255, 0, 0, 20);
        currentPreviousPositionsCircle.draw();
        fill(255, 0, 0, 20);
        currentPreviousPositionsForbiddenCircle.draw();

        fill(255, 0, 0, 150);
        for (int i = 0; i < forbiddenAreas.size(); i++)
        {
            forbiddenAreas.get(i).draw();
        }

        fill(0, 0, 255, 200);
        for (int i = 0; i < obstacles.length; i++)
        {
            obstacles[i].draw();
        }

        fill(255, 0, 0);
        for (int i = 0; i < previousBestPositions.size(); i++)
        {
            PVector p = previousBestPositions.get(i);
            ellipse(p.x, p.y, 6, 6);
        }

        fill(0, 255, 0);
        goal.draw();

        for (int i = 0; i < dots.length; i++)
        {
            if (dots[i].mode == 0)
            {
                dots[i].show();
            }
        }

        for (int i = 0; i < dots.length; i++)
        {
            if (dots[i].mode != 0)
            {
                dots[i].show();
            }
        }
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // update all dots
    void update()
    {
        for (int i = 0; i< dots.length; i++)
        {
            this.dots[i].update();
        }
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // calculate the step constant to be set to all the dots
    void calculateAverages()
    {
        float sumStep = 0;
        float sumDistance = 0;
        for (int i = 0; i< dots.length; i++)
        {
            sumStep += this.dots[i].step;
            sumDistance += this.dots[i].pos.dist(this.goalCenter);
        }
        this.averageStep = sumStep / this.dots.length;
        this.averageDistance = sumDistance / this.dots.length;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // returns whether all the dots are either dead or have reached the goal
    boolean allDotsDead()
    {
        for (int i = 0; i< dots.length; i++)
        {
            if (!dots[i].dead)
            {
                return false;
            }
        }
        return true;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // gets the next generation of dots
    void breedNextGeneration()
    {
        Dot[] newDots = new Dot[dots.length]; // next gen
        this.calculateFitnessSum();

        {
            int sz = 0;
            java.util.HashMap<Dot, Dot> enteredDots = new java.util.HashMap<Dot, Dot>();

            this.sortDots(true);
            for (int j = 0; j < newDots.length / 10; j++)
            {
                Dot t = dots[j].clone();
                enteredDots.put(dots[j], t);
                if (j == 0)
                {
                    t.mode = 1;
                }
                newDots[sz++] = t;
            }

            this.sortDots(false);
            for (int j = 0; j < newDots.length / 10; j++)
            {
                if (enteredDots.containsKey(dots[j]))
                {
                    if (j == 0)
                    {
                        Dot t = enteredDots.get(dots[j]);
                        if (t.mode == 0)
                        {
                            t.mode = 2;
                        }
                    }
                    continue;
                }
                Dot t = dots[j].clone();
                if (j == 0)
                {
                    t.mode = 2;
                }
                newDots[sz++] = t;
            }

            for (int j = 0; j < newDots.length / 10; j++)
            {
                Dot t = new Dot(this, brainSize);
                t.brain.randomize();
                newDots[sz++] = t;
            }

            // the dots are already sorted by fitness
            // add a tenth copies of the best
            // we want to forbid the area, so we have to be sure that it is a bad one
            for (int j = 0; j < newDots.length / 10; j++)
            {
                Dot t = dots[0].clone();
                t.brain.mutate(0.01);
                newDots[sz++] = t;
            }

            int third = (newDots.length - sz) / 3;
            for (int j = 0; j < third; j++)
            {
                // select a parent based on fitness and get a baby from them
                Dot t = selectParent().clone();
                t.brain.mutate(0.01);
                newDots[sz++] = t;
            }
            for (int j = 0; j < third; j++)
            {
                // select a parent based on fitness and get a baby from them
                Dot t = selectParent().clone();
                t.brain.mutate(0.05);
                newDots[sz++] = t;
            }
            for (; sz < newDots.length; )
            {
                // select a parent based on fitness and get a baby from them
                Dot t = selectParent().clone();
                t.brain.mutate(0.1);
                newDots[sz++] = t;
            }
        }

        // the dots are already sorted by fitness
        this.previousBestPositions.add(this.dots[0].pos);

        Circle newForbiddenArea = this.calculateForbiddenArea();
        if (newForbiddenArea != null)
        {
            forbiddenAreas.add(newForbiddenArea);
            previousBestPositions.clear();
        }

        this.calculateAverages();

        this.dots = newDots;
        this.gen++;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // calculate the possible new forbidden area
    Circle calculatePreviousPositionsCircle(int count, Circle res)
    {
        PVector t = new PVector();
        int size = this.previousBestPositions.size();
        for (int i = 0; i < count; i++)
        {
            t.add(this.previousBestPositions.get(size - 1 - i));
        }
        t.div(count);

        float radius = 0;
        for (int i = 0; i < count; i++)
        {
            float d = t.dist(this.previousBestPositions.get(size - 1 - i));
            if (radius < d)
            {
                radius = d;
            }
        }

        if (res == null)
        {
            res = new Circle();
        }
        return (Circle) res.setFromCenterSize(t.x, t.y, radius);
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // calculate the possible new forbidden area
    int countDotsIn(Shape shape)
    {
        int res = 0;
        for (int i = 0; i < this.dots.length; i++)
        {
            if (shape.isInside(this.dots[i].pos))
            {
                res++;
            }
        }
        return res;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // calculate the possible new forbidden area
    Circle calculateForbiddenArea()
    {
        int size = this.previousBestPositions.size();

        Circle t = new Circle();

        this.calculatePreviousPositionsCircle(min(size, 10), t);
        this.currentPreviousPositionsCircle.set(t);
        this.currentPreviousPositionsForbiddenCircle.setFromCenterSize(t.cx(), t.cy(), previousPositionsForbiddenRadius);

        Circle forbiddenArea = new Circle();

        if (size >= 10)
        {
            this.calculatePreviousPositionsCircle(10, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (!this.forbiddenAreasForbiddenCircle.overlaps(forbiddenArea) &&
                    this.countDotsIn(forbiddenArea) >= this.dots.length / 5)
                {
                    println(String.format("** New forbidden area created. 10 generations, %d dots, not near goal.", this.countDotsIn(forbiddenArea)));
                    return forbiddenArea;
                }
            }
        }

        if (size >= 20)
        {
            this.calculatePreviousPositionsCircle(20, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (this.countDotsIn(forbiddenArea) >= this.dots.length / 5 &&
                    !this.goal.overlaps(forbiddenArea))
                {
                    println(String.format("** New forbidden area created. 20 generations, %d dots.", this.countDotsIn(forbiddenArea)));
                    return forbiddenArea;
                }
            }
        }

        if (size >= 20)
        {
            this.calculatePreviousPositionsCircle(20, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (!this.forbiddenAreasForbiddenCircle.overlaps(forbiddenArea) &&
                    this.countDotsIn(forbiddenArea) >= this.dots.length / 10 &&
                    !this.goal.overlaps(forbiddenArea))
                {
                    println(String.format("** New forbidden area created. 20 generations, %d dots, not near goal.", this.countDotsIn(forbiddenArea)));
                    return forbiddenArea;
                }
            }
        }

        if (size >= 30)
        {
            this.calculatePreviousPositionsCircle(30, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (this.countDotsIn(forbiddenArea) >= this.dots.length / 10 &&
                    !this.goal.overlaps(forbiddenArea))
                {
                    println(String.format("** New forbidden area created. 30 generations, %d dots.", this.countDotsIn(forbiddenArea)));
                    return forbiddenArea;
                }
            }
        }

        if (size >= 30)
        {
            this.calculatePreviousPositionsCircle(30, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (!this.forbiddenAreasForbiddenCircle.overlaps(forbiddenArea) &&
                    !this.goal.overlaps(forbiddenArea))
                {
                    println(String.format("** New forbidden area created. 30 generations, not near goal."));
                    return forbiddenArea;
                }
            }
        }

        if (size >= 40)
        {
            this.calculatePreviousPositionsCircle(40, t);
            if (t.r() <= previousPositionsForbiddenRadius)
            {
                forbiddenArea.setFromCenterSize(t.cx(), t.cy(), forbiddenAreaRadius);
                if (!this.goal.overlaps(forbiddenArea))
                {
                    println(String.format("** New forbidden area created. 30 generations."));
                    return forbiddenArea;
                }
            }
        }

        return null;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // you get it
    void calculateFitnessSum()
    {
        fitnessSum = 0;
        for (int i = 0; i< dots.length; i++)
        {
            fitnessSum += dots[i].bestFitness;
        }
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // chooses dot from the population to return randomly(considering fitness)
    Dot selectParent()
    {
        // this function works by randomly choosing a value between 0 and the sum of all the fitnesses
        // then go through all the dots and add their fitness to a running sum and if that sum is greater than the random value generated that dot is chosen
        // since dots with a higher fitness function add more to the running sum then they have a higher chance of being chosen

        float rand = random(fitnessSum);
        float runningSum = 0;

        for (int i = 0; i< dots.length; i++)
        {
            runningSum+= dots[i].bestFitness;
            if (runningSum > rand)
            {
                return dots[i];
            }
        }

        // should never get to this point
        println("An error has occured.");
        return null;
    }

    // --------------------------------------------------------------------------------------------------------------------------------
    // sort all the dots based on bestFitness
    void sortDots(boolean best)
    {
        java.util.Comparator<Dot> cmp;
        if (best)
        {
            cmp = new java.util.Comparator<Dot>()
            {
                @Override
                public int compare(Dot a, Dot b)
                {
                    return -Float.compare(a.bestFitness, b.bestFitness);
                }
            };
        }
        else
        {
            cmp = new java.util.Comparator<Dot>()
            {
                @Override
                public int compare(Dot a, Dot b)
                {
                    return -Float.compare(a.fitness, b.fitness);
                }
            };
        }
        java.util.Arrays.sort(dots, cmp);
    }
}
