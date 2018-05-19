World world;

void setup() {
  size(800, 600); //size of the window
  frameRate(100);//increase this to make the dots go faster
  randomSeed(5365);
  world = new World(1000, 15);//create a new population with 1000 dots and 10 obstacles
  world.init();
}

void draw() {
  background(255);

  if (world.allDotsDead()) {
    println();

    world.sortDots(true);
    int bestStep = world.dots[0].step;
    for (int i = 0; i < 10; i++)
    {
      print(String.format("%.4f  ", world.dots[i].bestFitness));
    }
    println();

    world.sortDots(false);
    for (int i = 0; i < 10; i++)
    {
      Dot d = world.dots[i];
      d.printFitness();
    }
    println();

    println("best step:", bestStep);

    //genetic algorithm
    world.breedNextGeneration();

    println("generation:", world.gen);
  } else {
    //if any of the dots are still alive then update and then show them
    world.update();
    world.show();
  }
}
