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
    float[] fs = new float[test.dots.length];
    for (int i = 0; i < fs.length; i++)
    {
      fs[i] = test.dots[i].fitness;
    }
    fs = reverse(sort(fs));
    for (int i = 0; i < 10; i++)
    {
      print(fs[i], "  ");
    }
    println();
    for (int i = 0; i < fs.length; i++)
    {
      Dot d = test.dots[i];
      if (d.fitness <= fs[9])
      {
        d.printFitness();
      }
    }
    println();
    //genetic algorithm
    test.naturalSelection();
    test.mutateDemBabies();
    test.clearBestFitnesses();
  } else {
    //if any of the dots are still alive then update and then show them
    test.update();
    test.show();
  }
}
