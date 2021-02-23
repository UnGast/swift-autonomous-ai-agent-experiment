public protocol ComputationModule: AnyComputationModule {
  associatedtype Input
  associatedtype Output

  func forward(_ input: Input) -> Output
}

public protocol AnyComputationModule {
  func resolveParameterSets() -> [ComputationParameterSet]
}

extension AnyComputationModule {
  public func resolveParameterSets() -> [ComputationParameterSet] {
    var parameterSets = [ComputationParameterSet]()
    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if let parameterSet = child.value as? ComputationParameterSet {
        parameterSets.append(parameterSet)
      }
      if let module = child.value as? AnyComputationModule {
        parameterSets.append(contentsOf: module.resolveParameterSets())
      }
    }
    return parameterSets
  }
}