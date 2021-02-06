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

  public func fill(min: SIMD2<Int>, max: SIMD2<Int>) {
    for x in min.x..<max.x {
      for y in min.y..<max.y {
        self[[x, y]] = .solid
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

  public func difference(to other: Area) -> Double {
    var totalDifference = 0
    for x in 0..<size.x {
      for y in 0..<size.y {
        if self[[x, y]] != other[[x, y]] {
          totalDifference += 1
        }
      }
    }
    return Double(totalDifference) / Double(size.x * size.y)
  }
}

public enum CellTypes: Int, CustomStringConvertible {
  case void, solid

  public var description: String {
    String(rawValue)
  }
}

let size = SIMD2(10, 10)
let targetShape = Area(size: size)
targetShape.fill(min: [2, 2], max: [8, 8])
print(targetShape)

public enum CellAction: Int {
  case growLeft, growTop, growRight, growBottom
}

public class Parameter {
  public var value: Float

  public init(_ value: Float) {
    self.value = value
  }
}

public class Computation {
  public var parameters: [Parameter] {
    fatalError("not implemented")
  }

  public func callAsFunction(_ input: [Float]) -> [Float] {
    fatalError("not implemented")
  }

  public class Linear: Computation {
    public let inFeatures: Int
    public let outFeatures: Int
    public var weights: [[Parameter]]
    public var bias: [Parameter]
    public override var parameters: [Parameter] {
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
  }
}

// TODO: implement something like .mutate() on policy --> clone and then change params,
// maybe add another type ParameterMutation, to keep track of mutations, generate mutations, and apply mutations that already worked again

public class Policy {
  public var computation: Computation = Computation.Linear(2, 4)

  public func getActions(at position: SIMD2<Int>) -> [CellAction] {
    let computationResult = computation([Float(position.x), Float(position.y)])
    let activeIndices = computationResult.enumerated().filter { $0.element > 0 }.map { $0.offset }
    return activeIndices.compactMap { CellAction(rawValue: Int($0)) }
  }
}

var policy = Policy()
var evolvedShape = Area(size: size)
var positionQueue = [SIMD2(0, 0)]

var iteration = 0
while positionQueue.count > 0 && iteration < 3 {
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

  let difference = targetShape.difference(to: evolvedShape)

  print(evolvedShape)
  print("DIFF", difference)
  print("------------------------")

  iteration += 1
}