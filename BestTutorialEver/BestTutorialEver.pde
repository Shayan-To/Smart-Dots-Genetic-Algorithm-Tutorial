Population test;

void setup() {
  size(800, 600); //size of the window
  frameRate(100);//increase this to make the dots go faster
  randomSeed(5366);
  test = new Population(1000, 20);//create a new population with 1000 dots and 10 obstacles
}

void draw() {
  background(255);

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
      d.printFitness(test.goal);
    }
    println();

    println("best step:", bestStep);

    //genetic algorithm
    test.naturalSelection();
    test.mutateDemBabies();
    test.clearBestFitnesses();
    test.gen++;

    println("generation:", test.gen);
  } else {
    //if any of the dots are still alive then update and then show them
    test.update();
    test.show();
  }
}
