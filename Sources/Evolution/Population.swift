public class Population<E: Evolvable> {
  public var individuals: [E]
  public var fittestIndividual: E {
    individuals.sorted { $0.fitness > $1.fitness }[0]
  }

  public init(individuals: [E]) {
    self.individuals = individuals
  }
}