class Brain
{
  PVector[] directions; // series of vectors which get the dot to the goal (hopefully)

  Brain(int size)
  {
    directions = new PVector[size];
  }

  // --------------------------------------------------------------------------------------------------------------------------------
  // creates a random vector
  PVector randomVector()
  {
    PVector r = PVector.fromAngle(random(2*PI));
    r.mult(random(1.5));
    return r;
  }

  // --------------------------------------------------------------------------------------------------------------------------------
  // sets all the vectors in directions to a random vector with length 1
  void randomize()
  {
    for (int i = 0; i< directions.length; i++)
    {
      directions[i] = randomVector();
    }
  }

  // --------------------------------------------------------------------------------------------------------------------------------
  // returns a perfect copy of this brain object
  Brain clone()
  {
    Brain clone = new Brain(directions.length);
    for (int i = 0; i < directions.length; i++)
    {
      clone.directions[i] = directions[i].copy();
    }
    return clone;
  }

  // --------------------------------------------------------------------------------------------------------------------------------
  // mutates the brain by setting some of the directions to random vectors
  void mutate(float mutationRate // chance that any vector in directions gets changed
             )
  {
    for (int i = 0; i < directions.length; i++)
    {
      float rand = random(1);
      if (rand < mutationRate)
      {
        // set this direction as a random direction
        directions[i] = randomVector();
      }
    }
  }
}
