class Dot {
  final PVector pos = new PVector();
  final PVector vel = new PVector();
  final PVector acc = new PVector();
  final Brain brain;
  final World world;

  int step = 0;

  boolean dead = false;

  int mode = 0;

  float fitness = 0;
  float bestFitness = 0;

  Dot(World world, Brain brain)
  {
    this.world = world;
    this.brain = brain;//new brain with brainSize instruction
    this.pos.set(this.world.startPoint);
  }

  Dot(World world, int brainSize)
  {
    this(world, new Brain(brainSize));//new brain with brainSize instruction
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
      acc.set(brain.directions[step]);
      step++;
    } else {//if at the end of the directions array then the dot is dead
      dead = true;
    }

    //apply the acceleration and move the dot
    vel.add(acc);
    vel.limit(5);//not too fast
    pos.add(vel);
  }

  //-------------------------------------------------------------------------------------------------------------------
  //calls the move function and check for collisions and stuff
  void update()
  {
    if (!this.dead) {
      this.move();
      this.calculateFitness();

      if (!this.world.screenRect.isInside(this.pos)) {//if near the edges of the window then kill it
        this.dead = true;
        return;
      }
      if (this.world.goal.isInside(this.pos)) {//if reached goal
        this.dead = true;
        return;
      }

      for (int j = 0; j < this.world.obstacles.length; j++)
      {
        if (this.world.obstacles[j].isInside(this.pos)) //if hit obstacle
        {
          this.dead = true;
          return;
        }
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  //calculates the fitness
  void calculateFitness() {
    float distanceToGoal = pos.dist(this.world.goal.center());
    if (distanceToGoal < this.world.goal.r())
    {
      distanceToGoal = this.world.goal.r();
    }
    // between 0 and 1
    this.fitness = this.world.goal.r() / distanceToGoal;
    if (this.world.stepCountingArea.isInside(this.pos))
    {
      // between 0 and maybe a bit less than 1
      // (stepConst = averageSteps * 0.7)
      this.fitness += this.world.stepConst / this.step;
    }
    if (this.bestFitness < this.fitness)
    {
      this.bestFitness = this.fitness;
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------
  //print the fitness
  void printFitness() {
    float distanceToGoal = this.pos.dist(this.world.goal.center());
    if (distanceToGoal < this.world.goal.r())
    {
      distanceToGoal = this.world.goal.r();
    }
    print(String.format("[%.4f", this.world.goal.r() / distanceToGoal));
    if (this.world.stepCountingArea.isInside(this.pos))
    {
      print(String.format("+%.4f", this.world.stepConst / this.step));
    }
    print(String.format("=%.4f]  ", this.fitness));
  }

  //---------------------------------------------------------------------------------------------------------------------------------------
  //clone it
  Dot clone() {
    return new Dot(this.world, this.brain.clone()); // babies have the same brain as their parents
  }
}
