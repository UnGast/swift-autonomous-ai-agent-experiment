import Foundation

public class Area: CustomDebugStringConvertible {
  public var size: SIMD2<Int>
  public var cells: [SIMD2<Int>: CellTypes] = [:]

  public init(size: SIMD2<Int>) {
    self.size = size
  }

  public subscript(_ position: SIMD2<Int>) -> CellTypes {
    get {
      cells[position] ?? .void
    }
    set {
      cells[position] = .solid
    }
  }

  public func rect(min: SIMD2<Int>, max: SIMD2<Int>) {
    for x in min.x..<max.x {
      for y in min.y..<max.y {
        self[[x, y]] = .solid
      }
    }
  }

  public func circle(center: SIMD2<Int>, radius: Float) {
    for x in 0..<size.x {
      for y in 0..<size.y {
        if pow(Float(center.x - x), 2) + pow(Float(center.y - y), 2) < pow(radius, 2) {
          self[[x, y]] = .solid
        }
      }
    }
  }

  public var debugDescription: String {
    var description = ""
    for y in 0..<size.y {
      for x in 0..<size.x {
        description.append(self[[x, y]].description + " ")
      }
      description.append("\n")
    }
    return description
  }

  public func difference(to other: Area) -> Float {
    var totalDifference = 0
    for x in 0..<size.x {
      for y in 0..<size.y {
        if self[[x, y]] != other[[x, y]] {
          totalDifference += 1
        }
      }
    }
    return Float(totalDifference) / Float(size.x * size.y)
  }
}

public enum CellTypes: Int, CustomStringConvertible {
  case void, solid

  public var description: String {
    String(rawValue)
  }
}

let size = SIMD2(15, 15)
let targetShape = Area(size: size)
targetShape.rect(min: [2, 2], max: [8, 8])
//targetShape.circle(center: [5, 5], radius: 5)
print(targetShape)

public enum CellAction: Int {
  case growLeft, growTop, growRight, growBottom
}

final public class CellGrowthPolicy: Evolvable {
  public var fitness: Double = 0
  public var sourceMutation: Mutation<CellGrowthPolicy>? = nil

  public var computation: Computation = Computation.Sequential([
    Computation.Linear(2, 8),
    Computation.Relu(),
    Computation.Linear(8, 8),
    Computation.Relu(),
    Computation.Linear(8, 16),
    Computation.Relu(),
    Computation.Linear(16, 8),
    Computation.Relu(),
    Computation.Linear(8, 4),
    Computation.Relu(),
    Computation.Linear(4, 4)
  ])

  public func getActions(at position: SIMD2<Int>) -> [CellAction] {
    let computationResult = computation([Float(position.x), Float(position.y)])
    let activeIndices = computationResult.enumerated().filter { $0.element > 0 }.map { $0.offset }
    return activeIndices.compactMap { CellAction(rawValue: Int($0)) }
  }

  public func clone() -> CellGrowthPolicy {
    let result = CellGrowthPolicy()
    result.computation = computation.clone()
    return result
  }

  public static func getMutant(from mutation: Mutation<CellGrowthPolicy>) -> CellGrowthPolicy {
    switch mutation {
    case let .random(original, policy):
      let mutationNumbers = MutationV1.random(for: original.computation.parameters)
      let result = original.clone()
      mutationNumbers.apply(to: result.computation.parameters)
      return result
    case let .crossOver(originals, weights):
      return originals[0]
    }
  }

  public struct RandomMutationPolicy {
    public var multiplicationRange = -0.5..<0.5
    public var additionRange = -0.5..<0.5
    public var dropoutProbability = 0.9
  }
}

public class MutationV1 {
  public var mutationWeights: [Float]
  public var mutationBias: [Float]

  public init(mutationWeights: [Float], mutationBias: [Float]) {
    self.mutationWeights = mutationWeights
    self.mutationBias = mutationBias
  }

  public static func random(for parameters: [Parameter]) -> MutationV1 {
    let result = MutationV1(mutationWeights: parameters.map { _ in Float.random(in: -1..<1) }, mutationBias: parameters.map { _ in Float.random(in: -1..<1) })
    for i in 0..<result.mutationWeights.count {
      if Double.random(in: 0..<1) > 0.05 {
        result.mutationWeights[i] = 1
      }
      if Double.random(in: 0..<1) > 0.05 {
        result.mutationBias[i] = 0
      }
    }
    return result
  }

  public func apply(to parameters: [Parameter]) {
    for (index, parameter) in parameters.enumerated() {
      parameter.value *= mutationWeights[index]
      parameter.value += mutationBias[index]
    }
  }
}

// TODO: maybe make a class MutableAgent/MutableContainer, then have property wrappers for all the parameters that can be mutated -> automatically find all mutables
public func evaluatePolicy(_ policy: CellGrowthPolicy) -> Area {
  let evolvedShape = Area(size: size)
  var positionQueue = [SIMD2(1, 1)]

  var iteration = 0
  while positionQueue.count > 0 && iteration < 200 {
    let position = positionQueue.removeFirst()

    let actions = policy.getActions(at: position)
    for action in actions {
      switch action {
      case .growLeft:
        let leftPosition = position &- [1, 0]
        evolvedShape[leftPosition] = .solid
        positionQueue.append(leftPosition)
      case .growTop:
        let topPosition = position &+ [0, 1]
        evolvedShape[topPosition] = .solid
        positionQueue.append(topPosition)
      case .growRight:
        let rightPosition = position &+ [1, 0]
        evolvedShape[rightPosition] = .solid
        positionQueue.append(rightPosition)
      case .growBottom:
        let bottomPosition = position &- [0, 1]
        evolvedShape[bottomPosition] = .solid
        positionQueue.append(bottomPosition)
      }
    }

    iteration += 1
  }

  return evolvedShape
}

let evolution = Evolution(
  policy: EvolutionPolicy(),
  randomMutationPolicy: CellGrowthPolicy.RandomMutationPolicy(),
  initialPopulations: [
    Population(individuals: [CellGrowthPolicy()]),
    Population(individuals: [CellGrowthPolicy()])
  ],
  evaluateFitness: {
    1 / Double(targetShape.difference(to: evaluatePolicy($0)))
  })
evolution.onGenerationCompleted = {
  //print("fittest individual", evolution.fittestIndividual!.fitness)
  for (index, population) in evolution.populations.enumerated() {
    print("fittest individual in population", index)
    print(evaluatePolicy(population.fittestIndividual))
    print(population.fittestIndividual.fitness)
    print("#################")
  }
  print("---------------------------------------------------------")
}

/*for _ in 0..<5000 {
  evolution.stepOneGeneration()
}*/

openGuiControl(evolution)

/*
var currentGeneration = [CellGrowthPolicy]()
currentGeneration.append(CellGrowthPolicy())

for generationIndex in 0..<200 {
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

  currentGeneration = nextGeneration
}
*/