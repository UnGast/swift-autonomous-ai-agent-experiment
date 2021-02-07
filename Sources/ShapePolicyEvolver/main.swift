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
//targetShape.rect(min: [2, 2], max: [8, 8])
targetShape.circle(center: [5, 5], radius: 5)
print(targetShape)

public enum CellAction: Int {
  case growLeft, growTop, growRight, growBottom
}

public class Parameter: Equatable {
  public var value: Float

  public init(_ value: Float) {
    self.value = value
  }

  public func clone() -> Parameter {
    Parameter(value)
  }

  public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
    lhs.value == rhs.value
  }
}

public class Computation {
  public var parameters: [Parameter] {
    fatalError("not implemented")
  }

  public func callAsFunction(_ input: [Float]) -> [Float] {
    fatalError("not implemented")
  }

  public func clone() -> Computation {
    fatalError("not implemented")
  }

  public class Linear: Computation {
    public let inFeatures: Int
    public let outFeatures: Int
    public var weights: [[Parameter]]
    public var bias: [Parameter]
    override public var parameters: [Parameter] {
      weights.flatMap { $0 } + bias
    }

    public init(_ inFeatures: Int, _ outFeatures: Int) {
      self.inFeatures = inFeatures
      self.outFeatures = outFeatures
      self.weights = []
      for _ in 0..<outFeatures {
        weights.append((0..<inFeatures).map { _ in Parameter(0.5) })
      }
      self.bias = (0..<outFeatures).map { _ in Parameter(1) }
    }

    override public func callAsFunction(_ input: [Float]) -> [Float] {
      var accOutput = [Float]()
      for o in 0..<outFeatures {
        var output = bias[o].value
        for i in 0..<inFeatures {
          output += input[i] * weights[o][i].value
        }
        accOutput.append(output)
      }
      return accOutput
    }

    override public func clone() -> Computation {
      let result = Linear(inFeatures, outFeatures)
      result.weights = weights.reduce(into: [[Parameter]]()) {
        $0.append($1.map { $0.clone() })
      }
      result.bias = bias.map { $0.clone() }
      return result
    }
  }

  public class Relu: Computation {
    override public var parameters: [Parameter] {
      []
    }

    override public func callAsFunction(_ input: [Float]) -> [Float] {
      input.map { max(0, $0) }
    }

    override public func clone() -> Computation {
      Relu()
    }
  }

  public class Sequential: Computation {
    public let children: [Computation]

    override public var parameters: [Parameter] {
      children.flatMap { $0.parameters }
    }

    public init(_ children: [Computation]) {
      self.children = children
    }

    override public func callAsFunction(_ input: [Float]) -> [Float] {
      var intermediate = input
      for child in children {
        intermediate = child(intermediate)
      }
      return intermediate
    }

    override public func clone() -> Computation {
      Sequential(children.map { $0.clone() })
    }
  }
}

public class Policy {
  public var computation: Computation = Computation.Sequential([
    Computation.Linear(2, 8),
    Computation.Relu(),
    Computation.Linear(8, 4),
    Computation.Relu(),
    Computation.Linear(4, 4),
    Computation.Relu(),
    Computation.Linear(4, 4),
    Computation.Relu(),
    Computation.Linear(4, 4),
    Computation.Relu(),
    Computation.Linear(4, 4)
  ])

  public func getActions(at position: SIMD2<Int>) -> [CellAction] {
    let computationResult = computation([Float(position.x), Float(position.y)])
    let activeIndices = computationResult.enumerated().filter { $0.element > 0 }.map { $0.offset }
    return activeIndices.compactMap { CellAction(rawValue: Int($0)) }
  }

  public func clone() -> Policy {
    let result = Policy()
    result.computation = computation.clone()
    return result
  }
}

public class Mutation {
  public var mutationWeights: [Float]
  public var mutationBias: [Float]

  public init(mutationWeights: [Float], mutationBias: [Float]) {
    self.mutationWeights = mutationWeights
    self.mutationBias = mutationBias
  }

  public static func random(for parameters: [Parameter]) -> Mutation {
    let result = Mutation(mutationWeights: parameters.map { _ in Float.random(in: -1..<1) }, mutationBias: parameters.map { _ in Float.random(in: -1..<1) })
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

public func evaluatePolicy(_ policy: Policy) -> Area {
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

var currentGeneration = [Policy]()
currentGeneration.append(Policy())

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

  var individualsForReproduction = [Policy]()
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

  var nextGeneration = [Policy]()

  for parent in individualsForReproduction {
    nextGeneration.append(parent)
    for _ in 0..<10 {
      let mutation = Mutation.random(for: parent.computation.parameters)
      let child = parent.clone()
      mutation.apply(to: child.computation.parameters)
      nextGeneration.append(child)
    }
  }

  currentGeneration = nextGeneration
}
