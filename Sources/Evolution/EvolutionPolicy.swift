public struct EvolutionPolicy: Equatable {
  public var reproductionIndividualCount: Int = 10 
  public var offspringPerIndividualCount: Int = 10

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.reproductionIndividualCount == rhs.reproductionIndividualCount && lhs.offspringPerIndividualCount == rhs.offspringPerIndividualCount
  }
}