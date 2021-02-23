public class Linear: ComputationModule {
  let size: Int

  @ComputationParameterSet
  var weights: [Double]

  public init(size: Int) {
    self.size = size
    self.weights = Array(repeating: 0.0, count: size)
  }

  public func forward(_ input: [Double]) -> [Double] {
    var output = Array(repeating: 0.0, count: size)
    for index in 0..<size {
      output[index] = input[index] * weights[index]
    }
    return output
  }
}