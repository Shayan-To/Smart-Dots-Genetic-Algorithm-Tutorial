class Dot {
  PVector pos;
  PVector vel;
  PVector acc;
  Brain brain;

  int step = 0;

  boolean dead = false;
  boolean reachedGoal = false;

  int mode = 0;

  float fitness = 0;
  float bestFitness = 0;
  float stepConst = 300;

  private Dot(PVector pos) {
    //start the dots at the bottom of the window with a no velocity or acceleration
    this.pos = new PVector();
    this.pos.set(pos);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  Dot(PVector pos, int brainSize) {
    this(pos);
    brain = new Brain(brainSize);//new brain with brainSize instruction
  }

  //-----------------------------------------------------------------------------------------------------------------
  //draws the dot on the screen
  void show() {
    int size = 4;
    switch (mode) {
      case 0: //all other dots are just smaller black dots
        fill(0);
        break;
      case 1: //if this dot is the best dot from the previous generation then draw it as a big green dot
        fill(0, 255, 0);
        size = 6;
        break;
      case 2:
        fill(0, 0, 255);
        size = 6;
        break;
    }
    ellipse(pos.x, pos.y, size, size);
  }

  //-----------------------------------------------------------------------------------------------------------------------
  //moves the dot according to the brains directions
  void move() {
    if (brain.directions.length > step) {//if there are still directions left then set the acceleration as the next PVector in the direcitons array
      acc = brain.directions[step];
      step++;
    } else {//if at the end of the directions array then the dot is dead
      dead = true;
    }

    //apply the acceleration and move the dot
    vel.add(acc);
    vel.limit(5);//not too fast
    pos.add(vel);
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  //calculates the fitness
  void calculateFitness(Circle goal) {
    float distanceToGoal = pos.dist(goal.center());
    if (distanceToGoal < goal.r())
    {
      distanceToGoal = goal.r();
    }
    fitness = goal.r() / distanceToGoal;
    if (distanceToGoal < 100)
    {
      fitness += stepConst / step;
    }
    if (bestFitness < fitness)
    {
      bestFitness = fitness;
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  //print the fitness
  void printFitness(Circle goal) {
    float distanceToGoal = pos.dist(goal.center());
    if (distanceToGoal < goal.r())
    {
      distanceToGoal = goal.r();
    }
    print("[");
    print(goal.r() / distanceToGoal);
    if (distanceToGoal < 100) {
      print("+");
      print(stepConst / step);
    }
    print("=");
    print(fitness);
    print("]  ");
  }

  //---------------------------------------------------------------------------------------------------------------------------------------
  //clone it
  Dot clone(PVector pos) {
    Dot baby = new Dot(pos);
    baby.brain = brain.clone();//babies have the same brain as their parents
    return baby;
  }
}
