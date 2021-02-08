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