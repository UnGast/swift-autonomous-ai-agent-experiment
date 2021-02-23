import Evolution

extension AI {
  public struct Model {
    public func getAction(for observations: InputObservations) -> Agent.Action {
      .moveRight
    }
  }

  public final class EvolvableModelContainer: Evolvable {
    public var fitness: Double = 0.0
    public var sourceMutation: Mutation<EvolvableModelContainer>? = nil
    public var model: Model

    public init(model: Model) {
      self.model = model
    }

    public static func getMutant(from mutation: Mutation<EvolvableModelContainer>) -> EvolvableModelContainer {
      print("TODO: IMPLEMENT GET MUTATN FOR MODEL")
      switch mutation {
      case let .random(original, policy):
        return original
      case let .crossOver(originals, weights):
        return originals[0]
      }
    }

    public struct RandomMutationPolicy {
      public var mutationRate: Double
    }
  }
}