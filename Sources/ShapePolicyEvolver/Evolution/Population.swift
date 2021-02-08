public class Population<E: Evolvable> {
  public var individuals: [E]

  public init(individuals: [E]) {
    self.individuals = individuals
  }
}