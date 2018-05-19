class World {
  final int brainSize = 1000;
  final Rectangle screenRect = new Rectangle(2, 2, width - 4, height - 4);
  final Circle goal  = (Circle) new Circle().setFromCenterSize(400, 10, 5);
  final PVector startPoint = new PVector(screenRect.w() / 2, screenRect.h() - 10);

  final Rectangle goalMarginedRect = (Rectangle) new Rectangle().setFromCenterSize(goal.cx(), goal.cy(), 50);
  final Rectangle startMarginedRect = (Rectangle) new Rectangle().setFromCenterSize(startPoint.x, startPoint.y, 50);
  final int obstacleAreaMargin = 5;
  final int obstacleMinSize = 50;
  final int obstacleMaxSize = 200;
  final Rectangle obstacleAreaRect = new Rectangle(screenRect.x() + obstacleAreaMargin, screenRect.y() + obstacleAreaMargin,
                                                   screenRect.w() - obstacleAreaMargin * 2, screenRect.h() - obstacleAreaMargin * 2);

  final Circle stepCountingArea = (Circle) new Circle().setFromCenterSize(goal.cx(), goal.cy(), 100);

  final float forbiddenAreaRadius = 50;
  final float previousPositionsForbiddenRadius = 25;
  final Circle goalMarginedCircle = (Circle) new Circle().setFromCenterSize(goal.cx(), goal.cy(), 100 * 4 / PI);

  final Circle currentPreviousPositionsCircle = new Circle();
  final Circle currentPreviousPositionsForbiddenCircle = new Circle();

  Dot[] dots;
  Rectangle[] obstacles;
  final java.util.ArrayList<Circle> forbiddenAreas = new java.util.ArrayList<Circle>();

  final java.util.ArrayList<PVector> previousBestPositions = new java.util.ArrayList<PVector>();

  float fitnessSum;
  float stepConst = 300;
  int gen = 0;

  World(int dotsCount, int obstaclesCount) {
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

  //------------------------------------------------------------------------------------------------------------------------------
  //show all dots
  void show() {
    fill(255, 240, 240);
    currentPreviousPositionsCircle.draw();
    fill(255, 200, 200);
    currentPreviousPositionsForbiddenCircle.draw();

    fill(255, 0, 0);
    for (int i = 0; i < forbiddenAreas.size(); i++)
    {
      forbiddenAreas.get(i).draw();
    }

    fill(0, 0, 255);
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

    fill(255, 0, 0);
    goal.draw();

    for (int i = 0; i < dots.length; i++) {
      if (dots[i].mode == 0) {
        dots[i].show();
      }
    }

    for (int i = 0; i < dots.length; i++) {
      if (dots[i].mode != 0) {
        dots[i].show();
      }
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------
  //update all dots
  void update() {
    for (int i = 0; i< dots.length; i++) {
      this.dots[i].update();
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------
  //calculate the step constant to be set to all the dots
  void calculateStepConst() {
    float sum = 0;
    for (int i = 0; i< dots.length; i++) {
      sum += dots[i].step;
    }
    this.stepConst = sum / dots.length * 0.7;
  }

  //------------------------------------------------------------------------------------------------------------------------------------
  //returns whether all the dots are either dead or have reached the goal
  boolean allDotsDead() {
    for (int i = 0; i< dots.length; i++) {
      if (!dots[i].dead) {
        return false;
      }
    }
    return true;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------
  //gets the next generation of dots
  void breedNextGeneration() {
    Dot[] newDots = new Dot[dots.length];//next gen
    calculateFitnessSum();

    {
      int i = 0;
      java.util.HashSet<Dot> enteredDots = new java.util.HashSet<Dot>();

      this.sortDots(true);
      for (int j = 0; j < newDots.length / 10; j++)
      {
        enteredDots.add(dots[j]);
        Dot t = dots[j].clone();
        if (j == 0)
        {
          t.mode = 1;
        }
        newDots[i] = t;
        i++;
      }

      this.sortDots(false);
      for (int j = 0; j < newDots.length / 10; j++)
      {
        if (!enteredDots.add(dots[j]))
        {
          continue;
        }
        Dot t = dots[j].clone();
        if (j == 0)
        {
          t.mode = 2;
        }
        newDots[i] = t;
        i++;
      }

      for (int j = 0; j < newDots.length / 10; j++)
      {
        Dot t = new Dot(this, brainSize);
        t.brain.randomize();
        newDots[i] = t;
        i++;
      }

      int third = (newDots.length - i) / 3;
      for (int j = 0; j < third; j++) {
        //select a parent based on fitness and get a baby from them
        Dot t = selectParent().clone();
        t.brain.mutate(0.01);
        newDots[i] = t;
        i++;
      }
      for (int j = 0; j < third; j++) {
        //select a parent based on fitness and get a baby from them
        Dot t = selectParent().clone();
        t.brain.mutate(0.05);
        newDots[i] = t;
        i++;
      }
      for (; i < newDots.length; ) {
        //select a parent based on fitness and get a baby from them
        Dot t = selectParent().clone();
        t.brain.mutate(0.1);
        newDots[i] = t;
        i++;
      }
    }

    this.previousBestPositions.add(this.dots[0].pos);
    this.calculateForbiddenArea();

    this.dots = newDots;
    this.gen++;
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  // calculate the possible new forbidden area
  void calculateForbiddenArea()
  {
    PVector t = new PVector();
    int size = this.previousBestPositions.size();
    int cnt = min(size, 10);
    for (int i = 0; i < cnt; i++)
    {
      t.add(this.previousBestPositions.get(size - 1 - i));
    }
    t.div(cnt);

    float radius = 0;
    for (int i = 0; i < cnt; i++)
    {
      float d = t.dist(this.previousBestPositions.get(size - 1 - i));
      if (radius < d)
      {
        radius = d;
      }
    }

    this.currentPreviousPositionsCircle.setFromCenterSize(t.x, t.y, radius);
    this.currentPreviousPositionsForbiddenCircle.setFromCenterSize(t.x, t.y, previousPositionsForbiddenRadius);

    if (cnt == 10 & radius <= previousPositionsForbiddenRadius)
    {
      Circle forbiddenArea = (Circle) new Circle().setFromCenterSize(t.x, t.y, forbiddenAreaRadius);
      if (!goalMarginedCircle.overlaps(forbiddenArea))
      {
        forbiddenAreas.add(forbiddenArea);
        previousBestPositions.clear();
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  //you get it
  void calculateFitnessSum() {
    fitnessSum = 0;
    for (int i = 0; i< dots.length; i++) {
      fitnessSum += dots[i].bestFitness;
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------------------
  //chooses dot from the population to return randomly(considering fitness)
  Dot selectParent() {
    //this function works by randomly choosing a value between 0 and the sum of all the fitnesses
    //then go through all the dots and add their fitness to a running sum and if that sum is greater than the random value generated that dot is chosen
    //since dots with a higher fitness function add more to the running sum then they have a higher chance of being chosen

    float rand = random(fitnessSum);
    float runningSum = 0;

    for (int i = 0; i< dots.length; i++) {
      runningSum+= dots[i].bestFitness;
      if (runningSum > rand) {
        return dots[i];
      }
    }

    //should never get to this point
    println("An error has occured.");
    return null;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  //sort all the dots based on bestFitness
  void sortDots(boolean best) {
    java.util.Comparator<Dot> cmp;
    if (best)
    {
      cmp = new java.util.Comparator<Dot>() {
        @Override
        public int compare(Dot a, Dot b) {
          return -Float.compare(a.bestFitness, b.bestFitness);
        }
      };
    }
    else
    {
      cmp = new java.util.Comparator<Dot>() {
        @Override
        public int compare(Dot a, Dot b) {
          return -Float.compare(a.fitness, b.fitness);
        }
      };
    }
    java.util.Arrays.sort(dots, cmp);
  }
}
