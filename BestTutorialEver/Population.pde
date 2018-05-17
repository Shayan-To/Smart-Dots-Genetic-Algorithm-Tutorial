class Population {
  Dot[] dots;
  Rectangle[] obstacles;

  Rectangle screenRect = new Rectangle(2, 2, width - 4, height - 4);
  PVector goal  = new PVector(400, 10);
  PVector startPoint = new PVector(screenRect.w / 2, screenRect.h - 10);
  Rectangle goalRect = new Rectangle(goal.x - 5, goal.y - 5, 10, 10);

  Rectangle goalMarginedRect = new Rectangle(goal.x - 50, goal.y - 50, 100, 100);
  Rectangle startMarginedRect = new Rectangle(startPoint.x - 50, startPoint.y - 50, 100, 100);
  int obstacleAreaMargin = 5;
  int obstacleMinSize = 50;
  int obstacleMaxSize = 200;
  Rectangle obstacleAreaRect = new Rectangle(screenRect.x + obstacleAreaMargin, screenRect.y + obstacleAreaMargin,
                                             screenRect.w - obstacleAreaMargin * 2, screenRect.h - obstacleAreaMargin * 2);

  float fitnessSum;
  int gen = 1;

  int bestDot = 0; //the index of the best dot in the dots[]
  int bestBFDot = 0; //the index of the best dot in terms of betsFitness in the dots[]

  Population(int dotsCount, int obstaclesCount) {
    dots = new Dot[dotsCount];
    for (int i = 0; i < dotsCount; i++) {
      dots[i] = new Dot(startPoint, 1000);
      dots[i].brain.randomize();
    }

    obstacles = new Rectangle[obstaclesCount];
    for (int i = 0; i < obstaclesCount; i++)
    {
      float w = random(obstacleMaxSize - obstacleMinSize) + obstacleMinSize;
      float h = random(obstacleMaxSize - obstacleMinSize) + obstacleMinSize;
      Rectangle o = new Rectangle(random(obstacleAreaRect.w - w) + obstacleAreaRect.x,
                                  random(height - 200) + 50,
                                  w, h);
      if (goalMarginedRect.overlaps(o) | startMarginedRect.overlaps(o))
      {
        i--;
        continue;
      }
      obstacles[i] = o;
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------
  //show all dots
  void show() {
    //draw goal
    fill(255, 0, 0);
    ellipse(goal.x, goal.y, 10, 10);

    fill(0, 0, 255);
    for (int i = 0; i < obstacles.length; i++)
    {
      obstacles[i].draw();
    }

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
      Dot d = dots[i];
      if (!d.dead && !d.reachedGoal) {
        d.move();

        if (!screenRect.isInside(d.pos)) {//if near the edges of the window then kill it
          d.dead = true;
          continue;
        }
        if (dist(d.pos.x, d.pos.y, goal.x, goal.y) < 5) {//if reached goal
          d.reachedGoal = true;
        }

        for (int j = 0; j < obstacles.length; j++)
        {
          if (obstacles[j].isInside(d.pos)) //if hit obstacle
          {
            d.dead = true;
            break;
          }
        }
      }
    }

    calculateFitness();
  }

  //-----------------------------------------------------------------------------------------------------------------------------------
  //calculate all the fitnesses
  void calculateFitness() {
    for (int i = 0; i< dots.length; i++) {
      dots[i].calculateFitness(goal);
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------
  //calculate the step constant to be set to all the dots
  float calculateStepConst() {
    float sum = 0;
    for (int i = 0; i< dots.length; i++) {
      sum += dots[i].step;
    }
    return sum / dots.length * 2.5;
  }

  //------------------------------------------------------------------------------------------------------------------------------------
  //returns whether all the dots are either dead or have reached the goal
  boolean allDotsDead() {
    for (int i = 0; i< dots.length; i++) {
      if (!dots[i].dead && !dots[i].reachedGoal) {
        return false;
      }
    }
    return true;
  }

  //-------------------------------------------------------------------------------------------------------------------------------------
  //gets the next generation of dots
  void naturalSelection() {
    Dot[] newDots = new Dot[dots.length];//next gen
    setBestDot();
    calculateFitnessSum();
    float stepConst = calculateStepConst();

    //the champion lives on
    newDots[0] = dots[bestDot].clone(startPoint);
    newDots[0].mode = 1;
    newDots[1] = dots[bestBFDot].clone(startPoint);
    newDots[1].mode = 2;
    for (int i = 2; i< newDots.length; i++) {
      //select parent based on fitness
      Dot parent = selectParent();
      //get baby from them
      newDots[i] = parent.clone(startPoint);
    }
    for (int i = 0; i< newDots.length; i++) {
      newDots[i].stepConst = stepConst;
    }

    dots = newDots.clone();
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

  //------------------------------------------------------------------------------------------------------------------------------------------
  //mutates all the brains of the babies
  void mutateDemBabies() {
    this.sortDots(true);
    for (int i = 50; i < dots.length; i++)
    {
      dots[i].brain.mutate();
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  //sets 0 to bestFitness of all dots
  void clearBestFitnesses() {
    for (int i = 0; i < dots.length; i++)
    {
      dots[i].bestFitness = 0;
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------
  //finds the dot with the highest fitness and sets it as the best dot
  void setBestDot() {
    float max = 0;
    float maxBF = 0;
    int maxIndex = 0;
    int maxBFIndex = 0;
    for (int i = 0; i < dots.length; i++) {
      if (dots[i].fitness > max) {
        max = dots[i].fitness;
        maxIndex = i;
      }
      if (dots[i].bestFitness > maxBF) {
        maxBF = dots[i].bestFitness;
        maxBFIndex = i;
      }
    }

    bestDot = maxIndex;
    bestBFDot = maxBFIndex;
  }
}
