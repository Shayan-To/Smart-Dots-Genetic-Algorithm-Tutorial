class Population {
  Dot[] dots;

  float fitnessSum;
  int gen = 1;

  int bestDot = 0; //the index of the best dot in the dots[]

  Population(int size) {
    dots = new Dot[size];
    for (int i = 0; i< size; i++) {
      dots[i] = new Dot();
    }
  }

  //------------------------------------------------------------------------------------------------------------------------------
  //show all dots
  void show() {
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
      dots[i].update();
    }
    calculateFitness();
  }

  //-----------------------------------------------------------------------------------------------------------------------------------
  //calculate all the fitnesses
  void calculateFitness() {
    for (int i = 0; i< dots.length; i++) {
      dots[i].calculateFitness();
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
    newDots[0] = dots[bestDot].clone();
    newDots[0].mode = 1;
    for (int i = 1; i< newDots.length; i++) {
      //select parent based on fitness
      Dot parent = selectParent();
      //get baby from them
      newDots[i] = parent.clone();
    }
    for (int i = 0; i< newDots.length; i++) {
      newDots[i].stepConst = stepConst;
    }

    dots = newDots.clone();
    gen ++;
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
    return null;
  }

  //------------------------------------------------------------------------------------------------------------------------------------------
  //mutates all the brains of the babies
  void mutateDemBabies() {
    float[] fs = new float[dots.length];
    for (int i = 0; i < dots.length; i++)
    {
      fs[i] = dots[i].bestFitness;
    }
    fs = reverse(sort(fs));
    for (int i = 0; i < dots.length; i++)
    {
      if (dots[i].bestFitness > fs[50])
      {
        dots[i].brain.mutate();
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------
  //finds the dot with the highest fitness and sets it as the best dot
  void setBestDot() {
    float max = 0;
    int maxIndex = 0;
    for (int i = 0; i < dots.length; i++) {
      if (dots[i].fitness > max) {
        max = dots[i].fitness;
        maxIndex = i;
      }
    }

    bestDot = maxIndex;

    //if this dot reached the goal then reset the minimum number of steps it takes to get to the goal
    println("best step:", dots[bestDot].step);
  }
}
