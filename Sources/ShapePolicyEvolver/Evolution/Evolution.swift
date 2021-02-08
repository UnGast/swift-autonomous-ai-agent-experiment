public class Evolution<E: Evolvable> {
  private var policy: EvolutionPolicy
  private var randomMutationPolicy: E.RandomMutationPolicy
  private var evaluateFitness: (E) -> Double

  private var populations: [Population<E>]
  public private(set) var fittestIndividual: E?

  public var onGenerationCompleted: (() -> ())? = nil

  public init(policy: EvolutionPolicy, randomMutationPolicy: E.RandomMutationPolicy, initialPopulations: [Population<E>], evaluateFitness: @escaping (E) -> Double) {
    self.policy = policy
    self.randomMutationPolicy = randomMutationPolicy
    self.populations = initialPopulations
    self.evaluateFitness = evaluateFitness
  }

  public func stepOneGeneration() {
    for population in populations {
      var currentGeneration = population.individuals

      for individual in currentGeneration {
        individual.fitness = evaluateFitness(individual)
      }

      currentGeneration.sort { $0.fitness > $1.fitness }

      if let fittest = fittestIndividual, currentGeneration[0].fitness > fittest.fitness {
        fittestIndividual = currentGeneration[0]
      } else {
        fittestIndividual = currentGeneration[0]
      }

      let selectedForReproduction = currentGeneration[0..<min(currentGeneration.count, policy.reproductionIndividualCount)]

      var nextGeneration = [E]()
      for parent in selectedForReproduction {
        nextGeneration.append(parent)
        for _ in 0..<policy.offspringPerIndividualCount {
          nextGeneration.append(E.getMutant(from: .random(original: parent, policy: randomMutationPolicy)))
        }
      }
      population.individuals = nextGeneration
    }
    /*print("EVOLVE ONE GEN")
    var individualScores = [Float]()
    var individualOutputs = [Area]()
    for individual in currentGeneration {
      let output = evaluatePolicy(individual)
      let score = targetShape.difference(to: output)
      individualScores.append(score)
      individualOutputs.append(output)
    }
    
    let individualsByScore = zip(individualScores, currentGeneration).enumerated().shuffled().sorted { $0.1.0 < $1.1.0 }

    print("best score in generation", generationIndex, individualsByScore[0].1.0)
    print(individualOutputs[individualsByScore[0].0])
    print("--------------------------------")

    var individualsForReproduction = [CellGrowthPolicy]()
    outer: for individual in individualsByScore.map({ $0.1.1 }) {
      if individualsForReproduction.count == 10 {
        break
      }

      for compareIndividual in individualsForReproduction {
        if individual.computation.parameters == compareIndividual.computation.parameters {
          continue outer
        }
      }

      individualsForReproduction.append(individual)
    }

    var nextGeneration = [CellGrowthPolicy]()

    for parent in individualsForReproduction {
      nextGeneration.append(parent)
      for _ in 0..<10 {
        let mutation = MutationV1.random(for: parent.computation.parameters)
        let child = parent.clone()
        mutation.apply(to: child.computation.parameters)
        nextGeneration.append(child)
      }
    }

    currentGeneration = nextGeneration*/

    if let handler = onGenerationCompleted {
      handler()
    }
  }
}