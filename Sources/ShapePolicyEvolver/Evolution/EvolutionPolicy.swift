import GraphicalControlApp

public struct EvolutionPolicy: Equatable {
  @Editable
  public var reproductionIndividualCount: Int = 10 
  @Editable
  public var offspringPerIndividualCount: Int = 10

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.reproductionIndividualCount == rhs.reproductionIndividualCount && lhs.offspringPerIndividualCount == rhs.offspringPerIndividualCount
  }
}