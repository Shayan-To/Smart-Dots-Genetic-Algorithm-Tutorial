Population test;
PVector goal  = new PVector(400, 10);

void setup() {
  size(800, 600); //size of the window
  frameRate(100);//increase this to make the dots go faster
  test = new Population(1000);//create a new population with 1000 members
}

void draw() { 
  background(255);

  //draw goal
  fill(255, 0, 0);
  ellipse(goal.x, goal.y, 10, 10);

  //draw obstacle(s)
  fill(0, 0, 255);
  rect(0, 300, 600, 10);

  if (test.allDotsDead()) {
    println();

    test.sortDots(true);
    int bestStep = test.dots[0].step;
    for (int i = 0; i < 10; i++)
    {
      print(test.dots[i].bestFitness, "  ");
    }
    println();

    test.sortDots(false);
    for (int i = 0; i < 10; i++)
    {
      Dot d = test.dots[i];
      d.printFitness();
    }
    println();

    println("best step:", bestStep);

    //genetic algorithm
    test.naturalSelection();
    test.mutateDemBabies();
    test.clearBestFitnesses();

    println("generation:", test.gen);
  } else {
    //if any of the dots are still alive then update and then show them
    test.update();
    test.show();
  }
}
